param location string

var vnetName = 'vnet-poc'
var vnetAddressSpace = '10.100.0.0/23'
var vpnSubnetPrefix = '10.100.0.0/27'
var appSubnetPrefix = '10.100.0.32/26'
var privateEndpointSubnetPrefix = '10.100.0.96/26'
var managementSubnetPrefix = '10.100.0.160/27'

resource vpnNsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: '${vnetName}-vpn-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-OpenVPN-UDP'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Udp'
          sourcePortRange: '*'
          destinationPortRange: '1194'
          sourceAddressPrefix: '*'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource appNsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: '${vnetName}-app-nsg'
  location: location
  properties: {
    securityRules: [
      {
        name: 'Allow-HTTPS-From-VNet'
        properties: {
          priority: 100
          direction: 'Inbound'
          access: 'Allow'
          protocol: 'Tcp'
          sourcePortRange: '*'
          destinationPortRange: '443'
          sourceAddressPrefix: 'VirtualNetwork'
          destinationAddressPrefix: '*'
        }
      }
    ]
  }
}

resource privateEndpointNsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: '${vnetName}-private-endpoint-nsg'
  location: location
  properties: {
    securityRules: []
  }
}

resource managementNsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  name: '${vnetName}-management-nsg'
  location: location
  properties: {
    securityRules: []
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressSpace
      ]
    }
    subnets: [
      {
        name: 'snet-vpn'
        properties: {
          addressPrefix: vpnSubnetPrefix
          networkSecurityGroup: {
            id: vpnNsg.id
          }
        }
      }
      {
        name: 'snet-app'
        properties: {
          addressPrefix: appSubnetPrefix
          networkSecurityGroup: {
            id: appNsg.id
          }
        }
      }
      {
        name: 'snet-private-endpoints'
        properties: {
          addressPrefix: privateEndpointSubnetPrefix
          networkSecurityGroup: {
            id: privateEndpointNsg.id
          }
          privateEndpointNetworkPolicies: 'Disabled'
        }
      }
      {
        name: 'snet-management'
        properties: {
          addressPrefix: managementSubnetPrefix
          networkSecurityGroup: {
            id: managementNsg.id
          }
        }
      }
    ]
  }
}

// Safely bind to the inline subnets to extract their resource IDs for outputs
resource vpnSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' existing = {
  parent: vnet
  name: 'snet-vpn'
}

resource appSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' existing = {
  parent: vnet
  name: 'snet-app'
}

resource privateEndpointSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' existing = {
  parent: vnet
  name: 'snet-private-endpoints'
}

resource managementSubnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' existing = {
  parent: vnet
  name: 'snet-management'
}

output vnetName string = vnet.name
output vnetId string = vnet.id
output vnetAddressSpace string = vnetAddressSpace
output vpnSubnetId string = vpnSubnet.id
output appSubnetId string = appSubnet.id
output privateEndpointSubnetId string = privateEndpointSubnet.id
output managementSubnetId string = managementSubnet.id

@description('Reserved OpenVPN client address pool. This is not an Azure subnet.')
output openVpnClientPool string = '10.100.8.0/24'
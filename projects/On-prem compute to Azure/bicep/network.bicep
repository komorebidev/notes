targetScope = 'subscription'

@description('Azure region where the resource group and networking resources will be created.')
param location string = 'koreacentral'

// -----------------------------------------------------------------------------
// Resource Group
// -----------------------------------------------------------------------------

var subscriptionSuffix = substring(subscription().id, length(subscription().id) - 4, 4)
var resourceGroupName = 'devrg-${subscriptionSuffix}'

resource resourceGroup 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceGroupName
  location: location
}

// -----------------------------------------------------------------------------
// Network Configuration
// -----------------------------------------------------------------------------

var vnetName = 'vnet-${subscriptionSuffix}'

var vnetAddressSpace = '10.100.0.0/23'

var vpnSubnetPrefix = '10.100.0.0/27'
var appSubnetPrefix = '10.100.0.32/26'
var privateEndpointSubnetPrefix = '10.100.0.96/26'
var managementSubnetPrefix = '10.100.0.160/27'

// -----------------------------------------------------------------------------
// Network Security Groups
// -----------------------------------------------------------------------------

resource vpnNsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  scope: resourceGroup
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
  scope: resourceGroup
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
  scope: resourceGroup
  name: '${vnetName}-private-endpoint-nsg'
  location: location

  properties: {
    securityRules: []
  }
}

resource managementNsg 'Microsoft.Network/networkSecurityGroups@2024-05-01' = {
  scope: resourceGroup
  name: '${vnetName}-management-nsg'
  location: location

  properties: {
    securityRules: []
  }
}

// -----------------------------------------------------------------------------
// Virtual Network
// -----------------------------------------------------------------------------

resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  scope: resourceGroup
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

// -----------------------------------------------------------------------------
// Outputs
// -----------------------------------------------------------------------------

output resourceGroupName string = resourceGroupName

output subscriptionId string = subscription().id

output vnetName string = vnet.name

output vnetId string = vnet.id

output vnetAddressSpace string = vnetAddressSpace

output vpnSubnetId string = resourceId(
  'Microsoft.Network/virtualNetworks/subnets',
  vnetName,
  'snet-vpn'
)

output appSubnetId string = resourceId(
  'Microsoft.Network/virtualNetworks/subnets',
  vnetName,
  'snet-app'
)

output privateEndpointSubnetId string = resourceId(
  'Microsoft.Network/virtualNetworks/subnets',
  vnetName,
  'snet-private-endpoints'
)

output managementSubnetId string = resourceId(
  'Microsoft.Network/virtualNetworks/subnets',
  vnetName,
  'snet-management'
)

@description('Reserved OpenVPN client address pool. This is not an Azure subnet.')
output openVpnClientPool string = '10.100.8.0/24'
targetScope = 'subscription'

@description('Azure region where the resource group and networking resources will be created.')
param location string = 'koreacentral'

var subscriptionSuffix = substring(subscription().id, length(subscription().id) - 4, 4)
var resourceGroupName = 'devrg-${subscriptionSuffix}'

@description('Admin username for the VMs passed from PowerShell')
param adminUsername string

@secure()
param adminPassword string

@description('Your local public IP passed from PowerShell')
param clientIp string

resource resourceGroup 'Microsoft.Resources/resourceGroups@2025-04-01' = {
  name: resourceGroupName
  location: location
}

module network './network.bicep' = {
  name: 'networkDeployment'
  scope: resourceGroup
  params: {
    location: location
    clientIp: clientIp
  }
}

module vpnVm './vpn-vm.bicep' = {
  name: 'vpnVmDeployment'
  scope: resourceGroup
  params: {
    location: location
    adminUsername: adminUsername
    adminPassword: adminPassword
    subnetId: network.outputs.vpnSubnetId
  }
}

module plantVm './plant-vm.bicep' = {
  name: 'plantVmDeployment'
  scope: resourceGroup
  params: {
    location: location
    adminUsername: adminUsername
    adminPassword: adminPassword
    subnetId: network.outputs.appSubnetId
  }
}

module privatednszone './privatednszone.bicep' = {
  name: 'privatednszoneDeployment'
  params: {
    location: location
    vnetId: network.outputs.vnetId
    privateDnsZoneName: 'corp.internal'
  }
}

output resourceGroupName string = resourceGroupName
output subscriptionId string = subscription().id
output vnetName string = network.outputs.vnetName
output vnetId string = network.outputs.vnetId
output vnetAddressSpace string = network.outputs.vnetAddressSpace
output vpnSubnetId string = network.outputs.vpnSubnetId
output appSubnetId string = network.outputs.appSubnetId
output privateEndpointSubnetId string = network.outputs.privateEndpointSubnetId
output managementSubnetId string = network.outputs.managementSubnetId

@description('Reserved OpenVPN client address pool. This is not an Azure subnet.')
output openVpnClientPool string = network.outputs.openVpnClientPool

output openVpnServerPublicIp string = vpnVm.outputs.vmPublicIpAddress
output plantVmPrivateIp string = plantVm.outputs.vmPrivateIpAddress
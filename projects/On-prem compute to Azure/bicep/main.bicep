targetScope = 'subscription'

@description('Azure region where the resource group and networking resources will be created.')
param location string = 'koreacentral'

var subscriptionSuffix = substring(subscription().id, length(subscription().id) - 4, 4)
var resourceGroupName = 'devrg-${subscriptionSuffix}'

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
  }
}

// ... keep your existing resource group and network module declarations ...

module vpnVm './vpn-vm.bicep' = {
  name: 'vpnVmDeployment'
  scope: resourceGroup
  params: {
    location: location
    adminUsername: 'azureuser'
    adminPassword: 'YourSecurePassword123!' // Replace or use a parameter/secure parameter
    clientIp: 'YOUR_PUBLIC_IP' // Replace with your local machine's public IP for SSH restriction
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

// vpn-vm
output openVpnServerPublicIp string = vpnVm.outputs.vmPublicIpAddress

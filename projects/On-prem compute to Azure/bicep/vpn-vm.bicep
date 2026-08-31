param location string
param adminUsername string
@secure()
param adminPassword string
param vmName string = 'vm-openvpn'
param subnetId string

resource publicIp 'Microsoft.Network/publicIPAddresses@2024-05-01' = {
  name: '${vmName}-pip'
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    publicIPAllocationMethod: 'Static'
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2024-05-01' = {
  name: '${vmName}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId
          }
          publicIPAddress: {
            id: publicIp.id
          }
        }
      }
    ]
  }
}

var cloudInit = base64(loadTextContent('./cloud-init.yaml'))

resource vm 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: vmName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_B2ats_v2'
    }
    osProfile: {
      computerName: vmName
      adminUsername: adminUsername
      adminPassword: adminPassword
      customData: cloudInit
    }
    storageProfile: {
      imageReference: {
        publisher: 'Debian'
        offer: 'debian-11'
        sku: '11'
        version: 'latest'
      }
      osDisk: {
        name: '${vmName}-disk'
        createOption: 'FromImage'
        diskSizeGB: 50
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}

output vmPublicIpAddress string = publicIp.properties.ipAddress
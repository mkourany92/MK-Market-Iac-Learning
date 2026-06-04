// Self-Hosted Agent VM Module
// WHY only for dev/test: eliminates agent cost in prod
// WHY B2s: burstable, cheap, good for build workloads
// WHY auto-shutdown at 19:00: saves approx 50% daily cost
// WHY no public IP: agents access Azure DevOps via HTTPS outbound only
// WHY system-assigned identity: agent reads ADO PAT from Key Vault

param vmName string
param location string
param tags object
param subnetId string
param adminUsername string = 'azuredevops'
param vmSize string = 'Standard_DS2_v2'
@secure()
param adminPassword string
param environment string = 'dev'
param scriptStorageBaseUrl string = ''
param dscPackageSasUrl string = ''

resource agentNic 'Microsoft.Network/networkInterfaces@2023-09-01' = {
  name: '${vmName}-nic'
  location: location
  tags: tags
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetId // WHY: Placed in management subnet, private, no public facing
          }
          privateIPAllocationMethod: 'Dynamic'
          // WHY no publicIPAddress: Agents push to Azure DevOps over HTTPS outbound only
          // No inbound required, no public IP needed
        }
      }
    ]
  }
}

resource agentVm 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: vmName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
    // WHY: VM reads Azure DevOps PAT from Key Vault using this identity
    // No PAT stored in scripts or environment variables
  }
  properties: {
    hardwareProfile: {
      vmSize: vmSize
    }
    securityProfile: {
      securityType: 'ConfidentialVM'
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
          // WHY Premium_LRS: faster IOPS = faster build times
          securityProfile: {
            securityEncryptionType: 'VMGuestStateOnly' // ← ADD THIS
            // WHY: Required for ConfidentialVM security type — encrypts VM guest state
          }
        }
        diskSizeGB: 128
      }
    }
    osProfile: {
      computerName: take(vmName, 15) // WHY: Windows limit is 15 chars; vmName can exceed that
      adminUsername: adminUsername
      adminPassword: adminPassword
      // NOTE: adminPassword is placeholder - real password set in Key Vault
      // Actual bootstrap uses DSC module to configure and uses KV secret
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: agentNic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: true
        // WHY: Boot diagnostics help debug VM startup issues via screenshot/serial log
      }
    }
  }
}

// Auto-shutdown schedule - saves ~50% VM cost by shutting down at 19:00 daily
resource autoShutdown 'Microsoft.DevTestLab/schedules@2018-09-15' = {
  name: 'shutdown-computevm-${vmName}'
  location: location
  tags: tags
  properties: {
    status: 'Enabled'
    taskType: 'ComputeVmShutdownTask'
    dailyRecurrence: {
      time: '1900' // WHY 19:00: End of business hours, agents not needed overnight
    }
    timeZoneId: 'UTC'
    targetResourceId: agentVm.id
    notificationSettings: {
      status: 'Disabled'
    }
  }
}

module vmExtensions './agent-vm-extensions.bicep' = {
  name: 'vm-extensions-${vmName}'
  params: {
    vmName: agentVm.name
    location: location
    tags: tags
    environment: environment
    scriptStorageBaseUrl: scriptStorageBaseUrl
    dscPackageSasUrl: dscPackageSasUrl
  }
}

output agentVmId string = agentVm.id
output agentVmName string = agentVm.name
output agentVmPrincipalId string = agentVm.identity.principalId
output agentNicId string = agentNic.id

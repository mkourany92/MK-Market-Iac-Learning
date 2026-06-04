// Agent VM Extensions
// Approach 1 (CSE)          → dev + test only: initial tool installation
// Approach 2 (MachineConfig) → prod only: continuous compliance enforcement

param vmName string
param location string
param tags object
param environment string
param scriptStorageBaseUrl string = '' // storage URL where agent-setup.ps1 is uploaded
param dscPackageSasUrl string = ''     // SAS URL to AgentToolsConfig.zip (prod only)

// Reference the existing VM to scope Guest Configuration assignment
resource existingVm 'Microsoft.Compute/virtualMachines@2024-03-01' existing = {
  name: vmName
}

// ── Approach 1: Custom Script Extension (dev + test) ─────────────────────────
// WHY CSE: runs PowerShell once on VM creation to install all agent tools
// WHY not prod: prod has deployAgentVm=false, so this module is never called for prod
resource customScriptExtension 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = if (environment != 'prod') {
  name: '${vmName}/AgentSetup'
  location: location
  tags: tags
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.10'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        '${scriptStorageBaseUrl}/scripts/agent-setup.ps1'
      ]
      commandToExecute: 'powershell -ExecutionPolicy Unrestricted -File agent-setup.ps1'
    }
  }
}

// ── Approach 2: Guest Configuration Extension prerequisite (prod) ─────────────
// WHY: This extension must be installed before any GuestConfiguration assignment
// WHY prod: continuous enforcement — Azure checks every 15 min and auto-corrects drift
resource guestConfigExtension 'Microsoft.Compute/virtualMachines/extensions@2023-03-01' = if (environment == 'prod') {
  name: '${vmName}/AzurePolicyforWindows'
  location: location
  tags: tags
  properties: {
    publisher: 'Microsoft.GuestConfiguration'
    type: 'ConfigurationforWindows'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {}
    protectedSettings: {}
  }
}

// ── Approach 2: Guest Configuration Assignment (prod) ─────────────────────────
// WHY ApplyAndAutoCorrect: detects drift AND fixes it automatically
// WHY dscPackageSasUrl guard: only assigns if package has been compiled and uploaded
resource guestConfigAssignment 'Microsoft.GuestConfiguration/guestConfigurationAssignments@2020-06-25' = if (environment == 'prod' && dscPackageSasUrl != '') {
  name: 'AgentToolsConfig'
  location: location
  scope: existingVm
  properties: {
    guestConfiguration: {
      name: 'AgentToolsConfig'
      version: '1.0.0'
      contentUri: dscPackageSasUrl
      assignmentType: 'ApplyAndAutoCorrect'
    }
  }
  dependsOn: [guestConfigExtension]
}

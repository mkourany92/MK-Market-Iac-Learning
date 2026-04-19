// Security Module Main
// Orchestrates: Key Vault, Managed Identities, RBAC assignments
// Principle: Zero-trust, least-privilege, no credentials in code

param environment string
param location string
param tags object
param tenantId string
param keyVaultName string

// For demo/lab, we define identity principal IDs here
// In prod, these come from compute module outputs
param appIdentityPrincipalId string = ''
param agentIdentityPrincipalId string = ''
param aksIdentityPrincipalId string = ''

// Placeholder storage/ACR IDs (compute module will provide these)
param storageAccountId string = ''
param acrId string = ''

// Deploy Key Vault
module keyVault './key-vault.bicep' = {
  name: 'kv-deploy'
  params: {
    keyVaultName: keyVaultName
    location: location
    tags: tags
    tenantId: tenantId
  }
}

// Deploy RBAC (if identities provided)
module rbac './rbac.bicep' = if (appIdentityPrincipalId != '') {
  name: 'rbac-deploy'
  params: {
    keyVaultId: keyVault.outputs.keyVaultId
    storageAccountId: storageAccountId
    acrId: acrId
    appIdentityPrincipalId: appIdentityPrincipalId
    agentIdentityPrincipalId: agentIdentityPrincipalId
    aksIdentityPrincipalId: aksIdentityPrincipalId
  }
}

output keyVaultId string = keyVault.outputs.keyVaultId
output keyVaultUri string = keyVault.outputs.keyVaultUri
output keyVaultName string = keyVault.outputs.keyVaultName

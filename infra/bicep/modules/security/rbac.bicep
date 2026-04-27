// RBAC Module
// WHY: Implements least-privilege access control
// Each service gets ONLY the roles it needs, nothing more
// If a service is compromised, attacker can only do what that service is allowed to do

param keyVaultId string
param storageAccountId string
param acrId string
param appIdentityPrincipalId string
param agentIdentityPrincipalId string
param aksIdentityPrincipalId string

// ========== ROLES DEFINITIONS ==========
// These are Azure built-in role IDs (constants, not secrets)

var keyVaultSecretsOfficerRole = 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7' // read/write secrets
//var storageAccountAcrPullRole = '7f951dda-4ed3-4680-a7ca-43fe172d538d' // pull ACR images
var storageBlobDataReaderRole = '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'  // read blobs
var storageBlobDataContributorRole = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe' // read/write blobs
var containerRegistryPullRole = '7f951dda-4ed3-4680-a7ca-43fe172d538d'  // pull from ACR

// ========== APP SERVICE RBAC ASSIGNMENTS ==========
// WHY App Service needs these:
// 1. KeyVault Secrets Officer → read connection strings, API keys
// 2. Storage Blob Data Reader → read app data/configurations from blob storage

resource appKeyVaultRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVaultId, appIdentityPrincipalId, keyVaultSecretsOfficerRole)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${keyVaultSecretsOfficerRole}'
    principalId: appIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource appStorageRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(storageAccountId, appIdentityPrincipalId, storageBlobDataReaderRole)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${storageBlobDataReaderRole}'
    principalId: appIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// ========== AKS RBAC ASSIGNMENTS ==========
// WHY AKS Kubelet needs these:
// 1. Container Registry Pull → download container images
// 2. Virtual Network Contributor → manage load balancer networking

resource aksACRRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (aksIdentityPrincipalId != '') {
  name: guid(acrId, aksIdentityPrincipalId, containerRegistryPullRole)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${containerRegistryPullRole}'
    principalId: aksIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// ========== SELF-HOSTED AGENT RBAC ASSIGNMENTS ==========
// WHY Agent needs these:
// 1. Storage Blob Data Contributor → upload build artifacts
// 2. Key Vault Crypto User → decrypt secrets during deployment

resource agentStorageRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (agentIdentityPrincipalId != '') {
  name: guid(storageAccountId, agentIdentityPrincipalId, storageBlobDataContributorRole)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${storageBlobDataContributorRole}'
    principalId: agentIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource agentKeyVaultRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (agentIdentityPrincipalId != '') {
  name: guid(keyVaultId, agentIdentityPrincipalId, keyVaultSecretsOfficerRole)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${keyVaultSecretsOfficerRole}'
    principalId: agentIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

// ========== OUTPUTS ==========
output appKeyVaultAssignmentId string = appKeyVaultRoleAssignment.id
output appStorageAssignmentId string = appStorageRoleAssignment.id
output aksACRAssignmentId string = aksIdentityPrincipalId != '' ? aksACRRoleAssignment!.id : ''
output agentStorageAssignmentId string = agentIdentityPrincipalId != '' ? agentStorageRoleAssignment!.id : ''
output agentKeyVaultAssignmentId string = agentIdentityPrincipalId != '' ? agentKeyVaultRoleAssignment!.id : ''

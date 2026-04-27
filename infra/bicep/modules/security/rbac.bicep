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
var keyVaultSecretsOfficerRole = 'b86a8fe4-44ce-4948-aee5-eccb2c155cd7'
//var storageAccountAcrPullRole = '7f951dda-4ed3-4680-a7ca-43fe172d538d'
var storageBlobDataReaderRole = '2a2b9908-6ea1-4ae2-8e65-a410df84e7d1'
var storageBlobDataContributorRole = 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'

// ========== ACR CROSS-RG MODULE ==========
// WHY: ACR lives in mkmarket-dev-rg. When deploying test/prod, this file runs in
//      mkmarket-test-rg or mkmarket-prod-rg. BCP139 forbids scoping a resource to
//      a different RG in the same file — must use a module instead.
// WHY split(acrId,'/')[4]: acrId is a full resource ID like
//      /subscriptions/.../resourceGroups/mkmarket-dev-rg/providers/.../mkmarketdevacr
//      index [4] extracts 'mkmarket-dev-rg', last() extracts 'mkmarketdevacr'
var acrRgName = split(acrId, '/')[4]
var acrResourceName = last(split(acrId, '/'))

module acrRbac './acr-rbac.bicep' = {
  name: 'acr-rbac-deploy'
  scope: resourceGroup(acrRgName) // always deploys into mkmarket-dev-rg
  params: {
    acrName: acrResourceName
    appIdentityPrincipalId: appIdentityPrincipalId
    aksIdentityPrincipalId: aksIdentityPrincipalId
  }
}

// ========== APP SERVICE RBAC ==========
// KeyVault and Storage ARE in the deployment RG → scope: resourceGroup() is correct here
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

// ========== SELF-HOSTED AGENT RBAC ==========
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
// WHY removed aksACRAssignmentId: aksACRRoleAssignment no longer exists here, it's in acr-rbac.bicep
output agentStorageAssignmentId string = agentIdentityPrincipalId != '' ? agentStorageRoleAssignment!.id : ''
output agentKeyVaultAssignmentId string = agentIdentityPrincipalId != '' ? agentKeyVaultRoleAssignment!.id : ''

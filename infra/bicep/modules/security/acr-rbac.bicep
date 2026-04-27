// ACR RBAC Module — deployed into ACR's resource group (mkmarket-dev-rg)
// WHY separate module: BCP139 — cross-RG role assignments require a module with matching scope

param acrName string
param appIdentityPrincipalId string
param aksIdentityPrincipalId string

var containerRegistryPullRole = '7f951dda-4ed3-4680-a7ca-43fe172d538d'

resource existingAcr 'Microsoft.ContainerRegistry/registries@2023-07-01' existing = {
  name: acrName
}

resource appAcrRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(existingAcr.id, appIdentityPrincipalId, containerRegistryPullRole)
  scope: existingAcr
  properties: {
    roleDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${containerRegistryPullRole}'
    principalId: appIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}

resource aksACRRoleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = if (aksIdentityPrincipalId != '') {
  name: guid(existingAcr.id, aksIdentityPrincipalId, containerRegistryPullRole)
  scope: existingAcr
  properties: {
    roleDefinitionId: '/subscriptions/${subscription().subscriptionId}/providers/Microsoft.Authorization/roleDefinitions/${containerRegistryPullRole}'
    principalId: aksIdentityPrincipalId
    principalType: 'ServicePrincipal'
  }
}
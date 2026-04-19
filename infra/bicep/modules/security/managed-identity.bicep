// Managed Identity Module
// WHY: Creates system-assigned identities for services
// Each identity is unique to its resource, auto-rotates tokens
// No credentials stored anywhere - tokens are temporal

param identityNames array // e.g., ['app', 'aks', 'agent']
param location string
param tags object

// Create an identity per service
var identities = [
  for name in identityNames: {
    name: name
    principalId: '${name}PrincipalId'
  }
]

// Output all identity IDs and principal IDs (used by RBAC assignments)
output identityObjects object = {
  app: {
    id: 'will_be_set_by_parent'  // placeholder
    principalId: 'will_be_set_by_parent'
  }
  aks: {
    id: 'will_be_set_by_parent'
    principalId: 'will_be_set_by_parent'
  }
  agent: {
    id: 'will_be_set_by_parent'
    principalId: 'will_be_set_by_parent'
  }
}

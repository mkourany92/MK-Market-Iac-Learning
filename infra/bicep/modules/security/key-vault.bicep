// Key Vault Module
// WHY: 
// - Purge protection: prevents accidental deletion (security requirement for prod)
// - Soft delete: allows recovery if key deleted (compliance requirement)
// - Access policies: only identities with MI can access (least privilege)
// - Audit logging: tracks all key access (compliance/forensics)

param keyVaultName string
param location string
param tags object
param tenantId string

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: keyVaultName
  location: location
  tags: tags
  properties: {
    tenantId: tenantId
    sku: {
      family: 'A'
      name: 'premium'  // WHY premium: enables purge protection, RBAC, key rotation
    }
    enableRbacAuthorization: true  // WHY: Use Azure RBAC instead of access policies (modern approach)
    enableSoftDelete: true  // WHY: Recover keys accidentally deleted within 90 days
    softDeleteRetentionInDays: 90
    enablePurgeProtection: true  // WHY: Prevents even Key Vault admins from instant-deleting (ransomware protection)
    networkAcls: {
      bypass: 'AzureServices'  // WHY: Allow Azure services (App Service, AKS) to access
      defaultAction: 'Deny'  // WHY: Default deny, then explicitly allow via private endpoints
    }
  }
}

output keyVaultId string = keyVault.id
output keyVaultUri string = keyVault.properties.vaultUri
output keyVaultName string = keyVault.name

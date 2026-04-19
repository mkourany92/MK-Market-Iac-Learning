param storageAccountName string
param acrName string
param location string
param tags object

@allowed([
  'Hot'
  'Cool'
])
param accessTier string = 'Hot'

@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param acrSku string = 'Basic'

module storageAccount './storage-account.bicep' = {
  name: 'storage-account'
  params: {
    storageAccountName: storageAccountName
    location: location
    tags: tags
    accessTier: accessTier
  }
}

module containerRegistry './container-registry.bicep' = {
  name: 'container-registry'
  params: {
    acrName: acrName
    location: location
    tags: tags
    acrSku: acrSku
  }
}

output storageAccountId string = storageAccount.outputs.storageAccountId
output storageAccountName string = storageAccount.outputs.storageAccountName
output primaryBlobEndpoint string = storageAccount.outputs.primaryBlobEndpoint
output acrId string = containerRegistry.outputs.acrId
output acrName string = containerRegistry.outputs.acrName
output acrLoginServer string = containerRegistry.outputs.loginServer

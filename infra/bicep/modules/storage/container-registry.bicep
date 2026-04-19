param acrName string
param location string
param tags object

@allowed([
  'Basic'
  'Standard'
  'Premium'
])
param acrSku string = 'Basic'

resource acr 'Microsoft.ContainerRegistry/registries@2023-07-01' = {
  name: acrName
  location: location
  tags: tags
  sku: {
    name: acrSku
  }
  properties: {
    adminUserEnabled: false
    anonymousPullEnabled: false
    publicNetworkAccess: 'Enabled'
    dataEndpointEnabled: false
  }
}

output acrId string = acr.id
output acrName string = acr.name
output loginServer string = acr.properties.loginServer

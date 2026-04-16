targetScope = 'resourceGroup'

@allowed([
  'dev'
  'test'
  'prod'
])
param environment string = 'dev'

param location string = 'eastus'
param projectName string = 'mkmarket-web-market'
param prefix string = 'mkmarket'
param owner string = 'mkmarket-owner'
param costCenter string = 'mkmarket-lab'

module foundation './modules/foundation/main.bicep' = {
  name: 'foundation-${environment}'
  params: {
    environment: environment
    location: location
    projectName: projectName
    prefix: prefix
    owner: owner
    costCenter: costCenter
  }
}


module network './modules/network/main.bicep' = {
  name: 'network-${environment}'
  params: {
    vnetName: '${foundation.outputs.namePrefix}-vnet'
    vnetCIDR: '10.0.0.0/16'
    location: location
    tags: foundation.outputs.commonTags
    environment: environment
    bastionEnabled: (environment != 'prod')
  }
  dependsOn: [
    foundation
  ]
}
output commonTags object = foundation.outputs.commonTags
output namePrefix string = foundation.outputs.namePrefix



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


output commonTags object = foundation.outputs.commonTags
output namePrefix string = foundation.outputs.namePrefix


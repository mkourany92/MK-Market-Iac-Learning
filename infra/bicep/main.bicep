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
param alertEmail string = 'replace-me@example.com'
param deployCompute bool = false
param deployAgentVm bool = environment != 'prod'

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
  dependsOn: [ foundation ]
}

module storage './modules/storage/main.bicep' = {
  name: 'storage-${environment}'
  params: {
    storageAccountName: toLower(replace('${foundation.outputs.namePrefix}st', '-', ''))
    acrName: toLower(replace('${foundation.outputs.namePrefix}acr', '-', ''))
    location: location
    tags: foundation.outputs.commonTags
    accessTier: (environment == 'prod' ? 'Cool' : 'Hot')
    acrSku: 'Basic'
  }
  dependsOn: [ foundation ]
}

module monitoring './modules/monitoring/main.bicep' = {
  name: 'monitoring-${environment}'
  params: {
    environment: environment
    location: location
    tags: foundation.outputs.commonTags
    prefix: foundation.outputs.namePrefix
    alertEmail: alertEmail
  }
  dependsOn: [ foundation ]
}

module compute './modules/compute/main.bicep' = if (deployCompute) {
  name: 'compute-${environment}'
  params: {
    environment: environment
    location: location
    tags: foundation.outputs.commonTags
    namePrefix: foundation.outputs.namePrefix
    aksSubnetId: network.outputs.aksSubnetId
    appServiceSubnetId: network.outputs.appserviceSubnetId
    managementSubnetId: network.outputs.managementSubnetId
    logAnalyticsWorkspaceId: monitoring.outputs.workspaceId
    appInsightsConnectionString: monitoring.outputs.appInsightsConnectionString
    keyVaultName: '${foundation.outputs.namePrefix}-kv'
    deployAgentVm: deployAgentVm
  }
  dependsOn: [ network, storage, monitoring ]
}
output commonTags object = foundation.outputs.commonTags
output namePrefix string = foundation.outputs.namePrefix
output vnetId string = network.outputs.vnetId
output storageAccountId string = storage.outputs.storageAccountId
output acrId string = storage.outputs.acrId
output acrLoginServer string = storage.outputs.acrLoginServer
output logAnalyticsWorkspaceId string = monitoring.outputs.workspaceId
output appInsightsId string = monitoring.outputs.appInsightsId
output actionGroupId string = monitoring.outputs.actionGroupId
output aksClusterId string = deployCompute ? compute.outputs.aksClusterId : ''
output aksClusterName string = deployCompute ? compute.outputs.aksClusterName : ''
output appServiceId string = deployCompute ? compute.outputs.appServiceId : ''
output agentVmId string = deployCompute ? compute.outputs.agentVmId : ''

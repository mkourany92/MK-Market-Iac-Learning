// Compute Module Main
// Orchestrates: AKS cluster, App Service, and self-hosted agent VM (dev/test only)
// Principle: agent VMs only where needed to stay inside 150 USD/month budget

param environment string
param location string
param tags object
param namePrefix string
param aksSubnetId string
param appServiceSubnetId string
param managementSubnetId string
param logAnalyticsWorkspaceId string
param appInsightsConnectionString string
param keyVaultName string
param deployAgentVm bool = environment != 'prod'


@allowed([
  'Standard_DS2_v2'
  'Standard_D2s_v3'
])
param vmSize string = 'Standard_DS2_v2'

var aksNodeCount = environment == 'prod' ? 2 : 1
var aksMinNodes = environment == 'prod' ? 2 : 1
var aksMaxNodes = environment == 'prod' ? 5 : 3
var aksVmSize = environment == 'prod' ? 'Standard_D2s_v3' : 'Standard_DS2_v2'
// WHY: Prod needs more stable compute; dev/test can burstable


module aksCluster './aks-cluster.bicep' = {
  name: 'aks-${environment}'
  params: {
    clusterName: '${namePrefix}-aks'
    location: location
    tags: tags
    aksSubnetId: aksSubnetId
    logAnalyticsWorkspaceId: logAnalyticsWorkspaceId
    nodeCount: aksNodeCount
    minNodeCount: aksMinNodes
    maxNodeCount: aksMaxNodes
    vmSize: aksVmSize
  }
}

module appService './app-service.bicep' = {
  name: 'app-${environment}'
  params: {
    appServicePlanName: '${namePrefix}-asp'
    appServiceName: '${namePrefix}-app'
    location: location
    tags: tags
    appServiceSubnetId: appServiceSubnetId
    appInsightsConnectionString: appInsightsConnectionString
    environment: environment
  }
}

// Self-hosted agent VM � only in dev and test, skipped in prod
module agentVm './agent-vm.bicep' = if (deployAgentVm) {
  name: 'agent-vm-${environment}'
  params: {
    vmName: '${namePrefix}-agent'
    location: location
    tags: tags
    subnetId: managementSubnetId
    vmSize: vmSize
    keyVaultName: keyVaultName
  }
}

output aksClusterId string = aksCluster.outputs.aksClusterId
output aksClusterName string = aksCluster.outputs.aksClusterName
output aksPrincipalId string = aksCluster.outputs.aksPrincipalId
output aksOidcIssuerUrl string = aksCluster.outputs.aksOidcIssuerUrl
output appServiceId string = appService.outputs.appServiceId
output appServiceName string = appService.outputs.appServiceName
output appServicePrincipalId string = appService.outputs.appServicePrincipalId
output appServiceDefaultHostname string = appService.outputs.appServiceDefaultHostname
output agentVmId string = deployAgentVm ? agentVm!.outputs.agentVmId : ''
output agentVmPrincipalId string = deployAgentVm ? agentVm!.outputs.agentVmPrincipalId : ''

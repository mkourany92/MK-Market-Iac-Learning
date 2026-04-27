// Compute Module Main
// Orchestrates: AKS cluster, App Service, and self-hosted agent VM (dev/test only)
// Principle: agent VMs only where needed to stay inside 150 USD/month budget

param environment string
param location string
param tags object
param namePrefix string
param aksSubnetId string
//param appServiceSubnetId string
param managementSubnetId string
param logAnalyticsWorkspaceId string
param appInsightsConnectionString string
@secure()
param adminPassword string = ''
param deployAgentVm bool = environment != 'prod'

param aksNodeVmSize string = 'Standard_DC2as_v5'
param agentVmSize string = 'Standard_DC2as_v5'
param deployAks bool = true
param deployAppService bool = true

param acrLoginServer string

var aksNodeCount = environment == 'prod' ? 2 : 1
var aksMinNodes = environment == 'prod' ? 2 : 1
var aksMaxNodes = environment == 'prod' ? 5 : 3


module aksCluster './aks-cluster.bicep' = if (deployAks) {
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
    vmSize: aksNodeVmSize
  }
}

module appService './app-service.bicep' = if (deployAppService) {
  name: 'app-${environment}'
  params: {
    appServicePlanName: '${namePrefix}-asp'
    appServiceName: '${namePrefix}-app'
    location: location
    tags: tags
    //appServiceSubnetId: appServiceSubnetId
    acrLoginServer: acrLoginServer
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
    vmSize: agentVmSize
    adminPassword: adminPassword   // ← add this line
  }
}

output aksClusterId string = deployAks ? aksCluster!.outputs.aksClusterId : ''
output aksClusterName string = deployAks ? aksCluster!.outputs.aksClusterName : ''
output aksPrincipalId string = deployAks ? aksCluster!.outputs.aksPrincipalId : ''
output aksOidcIssuerUrl string = deployAks ? aksCluster!.outputs.aksOidcIssuerUrl : ''
output appServiceId string = deployAppService ? appService!.outputs.appServiceId : ''
output appServiceName string = deployAppService ? appService!.outputs.appServiceName : ''
output appServicePrincipalId string = deployAppService ? appService!.outputs.appServicePrincipalId : ''
output appServiceDefaultHostname string = deployAppService ? appService!.outputs.appServiceDefaultHostname : ''
output agentVmId string = deployAgentVm ? agentVm!.outputs.agentVmId : ''
output agentVmPrincipalId string = deployAgentVm ? agentVm!.outputs.agentVmPrincipalId : ''

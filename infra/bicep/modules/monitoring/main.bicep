param environment string
param location string
param tags object
param prefix string
param alertEmail string

var retentionInDays = environment == 'prod' ? 90 : 30
var workspaceName = toLower(replace('${prefix}-${environment}-law', '-', ''))
var appInsightsName = '${prefix}-${environment}-appi'
var actionGroupName = '${prefix}-${environment}-ag'
var actionGroupShort = take(toLower(replace('${prefix}${environment}', '-', '')), 12)

module law './log-analytics.bicep' = {
  name: 'law-${environment}'
  params: {
    workspaceName: workspaceName
    location: location
    tags: tags
    retentionInDays: retentionInDays
  }
}

module appInsights './app-insights.bicep' = {
  name: 'appi-${environment}'
  params: {
    appInsightsName: appInsightsName
    location: location
    tags: tags
    workspaceResourceId: law.outputs.workspaceId
  }
}

module actionGroup './action-groups.bicep' = {
  name: 'ag-${environment}'
  params: {
    actionGroupName: actionGroupName
    location: 'global'
    tags: tags
    shortName: actionGroupShort
    alertEmail: alertEmail
  }
}

output workspaceId string = law.outputs.workspaceId
output workspaceName string = law.outputs.workspaceName
output workspaceCustomerId string = law.outputs.customerId
output appInsightsId string = appInsights.outputs.appInsightsId
output appInsightsName string = appInsights.outputs.appInsightsName
output appInsightsConnectionString string = appInsights.outputs.connectionString
output actionGroupId string = actionGroup.outputs.actionGroupId

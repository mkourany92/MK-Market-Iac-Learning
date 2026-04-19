// App Service Module
// WHY App Service Plan B1: cheapest tier with VNet integration support
// WHY system-assigned identity: app reads Key Vault secrets without credentials
// WHY HTTPS-only: no plain HTTP traffic in any environment

param appServicePlanName string
param appServiceName string
param location string
param tags object
param appServiceSubnetId string
param appInsightsConnectionString string
param environment string

var planSku = environment == 'prod' ? {
  name: 'P1v2'
  tier: 'PremiumV2'
  capacity: 1
} : {
  name: 'B1'
  tier: 'Basic'
  capacity: 1
}
// WHY: Prod uses P1v2 for SLA-backed uptime and autoscale support
// dev/test use B1 to stay inside 150 USD/month budget

resource appServicePlan 'Microsoft.Web/serverfarms@2023-12-01' = {
  name: appServicePlanName
  location: location
  tags: tags
  sku: planSku
  kind: 'linux'
  properties: {
    reserved: true   // WHY: Required flag for Linux App Service Plans
  }
}

resource appService 'Microsoft.Web/sites@2023-12-01' = {
  name: appServiceName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
    // WHY: App reads secrets from Key Vault using this identity
    // Principal ID is used to assign Key Vault Secrets Officer role
  }
  properties: {
    serverFarmId: appServicePlan.id
    httpsOnly: true   // WHY: Reject all plain HTTP requests at platform level
    virtualNetworkSubnetId: appServiceSubnetId  // WHY: VNet integration for private data access
    siteConfig: {
      linuxFxVersion: 'DOCKER|nginx:latest'   // placeholder, replaced by pipeline
      minTlsVersion: '1.2'   // WHY: Block TLS 1.0/1.1, only allow modern secure TLS
      ftpsState: 'Disabled'  // WHY: FTP is unencrypted, never needed in production
      http20Enabled: true    // WHY: HTTP/2 = better performance, multiplexing
      appSettings: [
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: appInsightsConnectionString
          // WHY: App Insights connection string enables request/exception telemetry
        }
        {
          name: 'ApplicationInsightsAgent_EXTENSION_VERSION'
          value: '~3'
        }
      ]
    }
  }
}

output appServicePlanId string = appServicePlan.id
output appServiceId string = appService.id
output appServiceName string = appService.name
output appServicePrincipalId string = appService.identity.principalId
output appServiceDefaultHostname string = appService.properties.defaultHostName

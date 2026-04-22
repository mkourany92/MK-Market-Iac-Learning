// Container Apps Module (replaces App Service)
// WHY Container Apps: no compute quota required, scales to zero, consumption billing
// WHY no VNet injection: existing appservice subnet is /24 — Container Apps needs /23 minimum
//   To enable VNet injection later: resize subnet to /23 + change delegation to Microsoft.App/environments
// WHY system-assigned identity: app reads Key Vault secrets without credentials
// WHY HTTPS-only: TLS terminated at Container Apps edge, HTTP redirected automatically

param appServicePlanName string       // used as Container Apps environment name
param appServiceName string           // used as container app name
param location string
param tags object
param appServiceSubnetId string       // reserved — VNet injection requires /23 + Microsoft.App/environments delegation
param appInsightsConnectionString string
param environment string

resource containerAppEnv 'Microsoft.App/managedEnvironments@2024-03-01' = {
  name: '${appServicePlanName}-env'
  location: location
  tags: tags
  properties: {
    // WHY no vnetConfiguration: subnet is /24, Container Apps VNet injection requires /23 minimum
    zoneRedundant: false  // WHY: dev/test does not need cross-zone HA
  }
}

resource containerApp 'Microsoft.App/containerApps@2024-03-01' = {
  name: appServiceName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
    // WHY: App reads Key Vault secrets using this identity — no credentials in config
  }
  properties: {
    managedEnvironmentId: containerAppEnv.id
    configuration: {
      ingress: {
        external: true        // WHY: Exposes HTTPS endpoint publicly; TLS handled by platform
        targetPort: 80
        transport: 'http'
        allowInsecure: false  // WHY: Reject plain HTTP, enforce HTTPS only
      }
    }
    template: {
      containers: [
        {
          name: appServiceName
          image: 'nginx:latest'  // placeholder, replaced by pipeline
          resources: {
            cpu: json('0.25')    // WHY: Minimum allocation — consumption billing = near-zero at idle
            memory: '0.5Gi'
          }
          env: [
            {
              name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
              value: appInsightsConnectionString
              // WHY: Enables App Insights telemetry without SDK changes
            }
          ]
        }
      ]
      scale: {
        minReplicas: environment == 'prod' ? 1 : 0
        // WHY 0 for dev/test: scales to zero when idle = $0 cost
        // WHY 1 for prod: avoids cold start on first request
        maxReplicas: environment == 'prod' ? 5 : 2
      }
    }
  }
}

output appServicePlanId string = containerAppEnv.id
output appServiceId string = containerApp.id
output appServiceName string = containerApp.name
output appServicePrincipalId string = containerApp.identity.principalId
output appServiceDefaultHostname string = containerApp.properties.configuration.ingress.fqdn

// AKS Cluster Module
// WHY Automatic SKU: managed upgrades, auto node provisioner, less manual ops
// WHY OIDC + Workload Identity: pods authenticate to Azure services without secrets
// WHY system-assigned identity: AKS manages load balancers + networking automatically

param clusterName string
param location string
param tags object
param aksSubnetId string
param logAnalyticsWorkspaceId string
param nodeCount int = 2
param minNodeCount int = 1
param maxNodeCount int = 3
param vmSize string = 'Standard_B2s'

resource aksCluster 'Microsoft.ContainerService/managedClusters@2024-02-01' = {
  name: clusterName
  location: location
  tags: tags
  identity: {
    type: 'SystemAssigned'
    // WHY SystemAssigned: auto-managed by Azure, rotated automatically
    // AKS uses this identity to manage load balancers, NSGs, and ACR pulls
  }
  properties: {
    dnsPrefix: clusterName
    enableRBAC: true   // WHY: Kubernetes RBAC enforces least-privilege on cluster resources
    oidcIssuerProfile: {
      enabled: true    // WHY: Required for workload identity (pods authenticate via OIDC)
    }
    securityProfile: {
      workloadIdentity: {
        enabled: true  // WHY: Modern replacement for aad-pod-identity, no secrets in pods
      }
    }
    agentPoolProfiles: [
      {
        name: 'system'
        count: nodeCount
        minCount: minNodeCount
        maxCount: maxNodeCount
        enableAutoScaling: true   // WHY: Scale to 0 in dev/test when idle = cost saving
        vmSize: vmSize
        osType: 'Linux'
        mode: 'System'
        osDiskType: 'Managed'
        osDiskSizeGB: 64
        vnetSubnetID: aksSubnetId  // WHY: Deploy nodes into private subnet, not default VNet
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'       // WHY: Azure CNI gives pods real VNet IPs (private endpoints work)
      networkPolicy: 'azure'       // WHY: Azure network policy = pod-to-pod traffic control
      serviceCidr: '172.16.0.0/16'
      dnsServiceIP: '172.16.0.10'
    }
    addonProfiles: {
      omsagent: {
        enabled: true              // WHY: Sends AKS node/pod metrics to Log Analytics automatically
        config: {
          logAnalyticsWorkspaceResourceID: logAnalyticsWorkspaceId
        }
      }
    }
    autoUpgradeProfile: {
      upgradeChannel: 'patch'      // WHY: Auto-apply security patches, avoid manual upgrade ops
    }
  }
}

output aksClusterId string = aksCluster.id
output aksClusterName string = aksCluster.name
output aksNodeResourceGroup string = aksCluster.properties.nodeResourceGroup
output aksPrincipalId string = aksCluster.identity.principalId
output aksOidcIssuerUrl string = aksCluster.properties.oidcIssuerProfile.issuerURL

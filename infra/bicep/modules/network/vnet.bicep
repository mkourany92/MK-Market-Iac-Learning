param vnetName string
param vnetCIDR string
param location string
param tags object

resource vnet 'Microsoft.Network/virtualNetworks@2023-04-01' = {
  name: vnetName
  location: location
  tags: tags
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetCIDR
      ]
    }
    subnets: [
      {
        name: 'management'
        properties: {
          addressPrefix: cidrSubnet(vnetCIDR, 26, 0)
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
      {
        name: 'aks'
        properties: {
          addressPrefix: cidrSubnet(vnetCIDR, 22, 1)
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
      {
        name: 'appservice'
        properties: {
          addressPrefix: cidrSubnet(vnetCIDR, 24, 8)
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
          delegations: [
            {
              name: 'delegation'
              properties: {
                serviceName: 'Microsoft.Web/serverFarms'
              }
            }
          ]
        }
      }
      {
        name: 'database'
        properties: {
          addressPrefix: cidrSubnet(vnetCIDR, 24, 12)
          privateEndpointNetworkPolicies: 'Disabled'
          privateLinkServiceNetworkPolicies: 'Disabled'
        }
      }
    ]
  }
}

output vnetId string = vnet.id
output vnetName string = vnet.name
output managementSubnetId string = '${vnet.id}/subnets/management'
output aksSubnetId string = '${vnet.id}/subnets/aks'
output appserviceSubnetId string = '${vnet.id}/subnets/appservice'
output databaseSubnetId string = '${vnet.id}/subnets/database'

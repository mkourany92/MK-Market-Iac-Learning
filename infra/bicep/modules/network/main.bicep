param vnetName string
param vnetCIDR string
param location string
param tags object
param environment string
param bastionEnabled bool

module vnet './vnet.bicep' = {
  name: 'vnet-module'
  params: {
    vnetName: vnetName
    vnetCIDR: vnetCIDR
    location: location
    tags: tags
  }
}

module mgmtNsg './nsg.bicep' = {
  name: 'nsg-management'
  params: {
    nsgName: '${vnetName}-nsg-management'
    location: location
    tags: tags
    environment: environment
  }
}

module aksNsg './nsg.bicep' = {
  name: 'nsg-aks'
  params: {
    nsgName: '${vnetName}-nsg-aks'
    location: location
    tags: tags
    environment: environment
  }
}

module appNsg './nsg.bicep' = {
  name: 'nsg-appservice'
  params: {
    nsgName: '${vnetName}-nsg-appservice'
    location: location
    tags: tags
    environment: environment
  }
}

module dbNsg './nsg.bicep' = {
  name: 'nsg-database'
  params: {
    nsgName: '${vnetName}-nsg-database'
    location: location
    tags: tags
    environment: environment
  }
}

output vnetId string = vnet.outputs.vnetId
output vnetName string = vnet.outputs.vnetName
output managementSubnetId string = vnet.outputs.managementSubnetId
output aksSubnetId string = vnet.outputs.aksSubnetId
output appserviceSubnetId string = vnet.outputs.appserviceSubnetId
output databaseSubnetId string = vnet.outputs.databaseSubnetId
output bastionEnabled bool = bastionEnabled

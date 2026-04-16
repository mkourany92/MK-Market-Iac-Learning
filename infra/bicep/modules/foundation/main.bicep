targetScope = 'resourceGroup'

@allowed([
  'dev'
  'test'
  'prod'
])
param environment string

param location string
param projectName string
param prefix string
param owner string
param costCenter string

var commonTags = {
  project: projectName
  environment: environment
  owner: owner
  'cost-center': costCenter
  'managed-by': 'bicep'
}

var namePrefix = '${prefix}-${environment}'

output commonTags object = commonTags
output namePrefix string = namePrefix
output environment string = environment
output location string = location

param actionGroupName string
param location string
param tags object
param shortName string
param alertEmail string

resource actionGroup 'Microsoft.Insights/actionGroups@2023-01-01' = {
  name: actionGroupName
  location: location
  tags: tags
  properties: {
    groupShortName: shortName
    enabled: true
    emailReceivers: [
      {
        name: 'primaryEmail'
        emailAddress: alertEmail
        useCommonAlertSchema: true
      }
    ]
  }
}

output actionGroupId string = actionGroup.id
output actionGroupName string = actionGroup.name

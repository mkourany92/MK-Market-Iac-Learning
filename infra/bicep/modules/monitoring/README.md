# Monitoring Module

Purpose:
- Central logging with Log Analytics
- Application telemetry with Application Insights
- Alert destination with Action Group

Design:
- Retention: 30 days for dev/test, 90 days for prod
- App Insights is workspace-based (single query surface with KQL)
- Action Group email receiver uses common alert schema

Inputs:
- environment
- location
- tags
- prefix
- alertEmail

Outputs:
- workspaceId, workspaceName, workspaceCustomerId
- appInsightsId, appInsightsName, appInsightsConnectionString
- actionGroupId

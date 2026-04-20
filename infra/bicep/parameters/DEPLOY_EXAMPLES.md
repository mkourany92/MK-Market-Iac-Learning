# Deploy script helper - not used yet, reference for Phase 4

# Example deploy to dev:
# az deployment group create `
#   --name mkmarket-dev-deploy-$(Get-Date -Format yyyyMMddHHmmss) `
#   --resource-group mkmarket-dev-rg `
#   --template-file infra/bicep/main.bicep `
#   --parameters infra/bicep/parameters/dev/main.parameters.json

# Example what-if preview:
# az deployment group what-if `
#   --resource-group mkmarket-dev-rg `
#   --template-file infra/bicep/main.bicep `
#   --parameters infra/bicep/parameters/dev/main.parameters.json

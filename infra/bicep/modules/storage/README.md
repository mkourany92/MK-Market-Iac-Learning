# Storage Module

## Purpose
Creates a secure Storage Account and Azure Container Registry for one environment.

## Design Decisions

### Storage Account
- Standard_LRS:
  Budget-friendly and enough for a lab.
- TLS 1.2 and HTTPS only:
  Enforces encrypted transport.
- allowBlobPublicAccess = false:
  Prevents anonymous blob/container exposure.
- allowSharedKeyAccess = false:
  Forces identity-based access instead of storage keys.
- defaultToOAuthAuthentication = true:
  Encourages Entra ID / Managed Identity flows.
- publicNetworkAccess = Enabled for now:
  Keeps the lab workable until private endpoints are added later.

### Container Registry
- Basic SKU:
  Lowest-cost good default for lab training.
- adminUserEnabled = false:
  Avoids static registry credentials.
- anonymousPullEnabled = false:
  Keeps images private.
- publicNetworkAccess = Enabled for now:
  Simplifies early pipeline and AKS integration; can be tightened later.

## Inputs
- storageAccountName
- acrName
- location
- tags
- accessTier
- acrSku

## Outputs
- storageAccountId
- storageAccountName
- primaryBlobEndpoint
- acrId
- acrName
- acrLoginServer

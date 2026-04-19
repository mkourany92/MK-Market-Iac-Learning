# Security Module

## Purpose
Implements zero-trust security architecture:
- Key Vault for secret storage with purge protection
- Managed identities for credential-less authentication
- Least-privilege RBAC for each service

## Security Design Principles

### 1. No Credentials in Code
- All secrets stored in Key Vault
- App accesses via Managed Identity token (auto-rotated)
- Even if code is compromised, attacker gains temporary token, not permanent credential

### 2. Least Privilege Access
Each service gets ONLY minimum roles:
- App Service: Read secrets + blobs
- AKS: Pull images from ACR
- Self-hosted agents: Upload artifacts + decrypt secrets

If service is compromised, damage is limited to that service's permissions.

### 3. Audit Trail
All Key Vault operations logged:
- Who accessed what
- When
- What action (read/write)
- Success/failure

Enables forensics and compliance audits.

### 4. Protection Against Ransomware
- Purge protection: prevents instant deletion
- Soft delete: 90-day recovery window
- Network policies: only Azure services can access
- RBAC: no key deletion by default

## Inputs
- environment: dev|test|prod
- location: Azure region
- tenantId: Azure Active Directory tenant ID
- keyVaultName: name of Key Vault
- appIdentityPrincipalId: system-managed identity of app
- agentIdentityPrincipalId: system-managed identity of build agent
- aksIdentityPrincipalId: system-managed identity of AKS cluster

## Outputs
- keyVaultId: resource ID (use in other modules)
- keyVaultUri: URI for app connections

## RBAC Assignments (Least Privilege Reference)

| Identity | Role | Scope | Reason |
|----------|------|-------|--------|
| App Service | KeyVault Secrets Officer | Key Vault only | Read connstrings/API keys |
| App Service | Storage Blob Data Reader | Storage acct only | Read app configs/data |
| AKS Kubelet | Container Registry Pull | ACR only | Download container images |
| Agent VM | Storage Blob Data Contributor | Storage acct only | Upload build artifacts |
| Agent VM | KeyVault Secrets Officer | Key Vault only | Decrypt secrets in deploy |

Note: Each role is scoped to ONLY the resource needed, not entire RG.

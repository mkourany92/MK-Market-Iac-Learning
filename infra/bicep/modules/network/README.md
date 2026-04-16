# Network Module

## Purpose
Creates VNet with 4 subnets, NSGs with secure default-deny rules.

## Inputs
- vnetName: VNet resource name
- vnetCIDR: Address space (e.g., 10.0.0.0/16)
- location: Azure region
- tags: Common tags object
- environment: dev|test|prod (for NSG rule tuning)
- bastionEnabled: bool (toggles Bastion availability)

## Subnets
- management (10.0.1.0/26): Bastion, self-hosted agents
- aks (10.0.4.0/22): AKS nodes
- appservice (10.0.8.0/24): App Service private integration
- database (10.0.12.0/24): Private endpoints to data services

## NSG Rules
- Default: DENY all inbound, DENY all outbound
- Allowed inbound: RDP 3389 (from Bastion), SSH 22 (from Bastion), HTTPS 443, HTTP 80, Kube API 6443 (internal)
- Allowed outbound: HTTPS 443 (internet), DNS 53, NTP 123, internal VNet traffic

## Outputs
- vnetId: VNet resource ID
- subnetIds: Network interface references
- bastionEnabled: Bastion toggle state

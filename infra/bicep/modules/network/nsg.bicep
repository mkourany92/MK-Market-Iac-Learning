param nsgName string
param location string
param tags object
param environment string

var nsgRules = [
  // Deny all inbound by default
  {
    name: 'DenyAllInbound'
    properties: {
      protocol: '*'
      sourcePortRange: '*'
      destinationPortRange: '*'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: '*'
      access: 'Deny'
      priority: 4096
      direction: 'Inbound'
    }
  }
  // Allow RDP 3389 from Bastion subnet (or restricted IP) - Inbound
  {
    name: 'AllowRDPFromBastion'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '3389'
      sourceAddressPrefix: '10.0.1.0/26'
      destinationAddressPrefix: '*'
      access: 'Allow'
      priority: 100
      direction: 'Inbound'
    }
  }
  // Allow SSH 22 from Bastion subnet - Inbound
  {
    name: 'AllowSSHFromBastion'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '22'
      sourceAddressPrefix: '10.0.1.0/26'
      destinationAddressPrefix: '*'
      access: 'Allow'
      priority: 110
      direction: 'Inbound'
    }
  }
  // Allow HTTPS 443 from load balancer / internet
  {
    name: 'AllowHTTPSInbound'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: '*'
      access: 'Allow'
      priority: 120
      direction: 'Inbound'
    }
  }
  // Allow HTTP 80 (redirect to HTTPS)
  {
    name: 'AllowHTTPInbound'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '80'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: '*'
      access: 'Allow'
      priority: 130
      direction: 'Inbound'
    }
  }
  // Allow Kubernetes API server 6443
  {
    name: 'AllowKubeAPIInbound'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '6443'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: '*'
      access: 'Allow'
      priority: 140
      direction: 'Inbound'
    }
  }
  // Deny all outbound by default
  {
    name: 'DenyAllOutbound'
    properties: {
      protocol: '*'
      sourcePortRange: '*'
      destinationPortRange: '*'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: '*'
      access: 'Deny'
      priority: 4096
      direction: 'Outbound'
    }
  }
  // Allow HTTPS 443 outbound to internet (Azure services, package managers)
  {
    name: 'AllowHTTPSOutbound'
    properties: {
      protocol: 'Tcp'
      sourcePortRange: '*'
      destinationPortRange: '443'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: 'Internet'
      access: 'Allow'
      priority: 100
      direction: 'Outbound'
    }
  }
  // Allow DNS 53 outbound
  {
    name: 'AllowDNSOutbound'
    properties: {
      protocol: 'Udp'
      sourcePortRange: '*'
      destinationPortRange: '53'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: 'Internet'
      access: 'Allow'
      priority: 110
      direction: 'Outbound'
    }
  }
  // Allow NTP 123 outbound
  {
    name: 'AllowNTPOutbound'
    properties: {
      protocol: 'Udp'
      sourcePortRange: '*'
      destinationPortRange: '123'
      sourceAddressPrefix: '*'
      destinationAddressPrefix: 'Internet'
      access: 'Allow'
      priority: 120
      direction: 'Outbound'
    }
  }
  // Allow internal traffic within VNet
  {
    name: 'AllowVNetOutbound'
    properties: {
      protocol: '*'
      sourcePortRange: '*'
      destinationPortRange: '*'
      sourceAddressPrefix: 'VirtualNetwork'
      destinationAddressPrefix: 'VirtualNetwork'
      access: 'Allow'
      priority: 130
      direction: 'Outbound'
    }
  }
]

resource nsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: nsgName
  location: location
  tags: tags
  properties: {
    securityRules: nsgRules
  }
}

output nsgId string = nsg.id
output nsgName string = nsg.name

# -----------------------------------------------
# RESOURCE GROUP
# -----------------------------------------------
resource "azurerm_resource_group" "hub" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# -----------------------------------------------
# HUB VNET
# -----------------------------------------------
resource "azurerm_virtual_network" "hub" {
  name                = "vnet-hub"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  address_space       = [var.hub_vnet_cidr]
  tags                = var.tags
}

# -----------------------------------------------
# SUBNETS
# These four subnet names are reserved by Azure
# and must be named exactly as shown
# -----------------------------------------------

# GatewaySubnet — for VPN or ExpressRoute gateway
# Cannot have NSG attached
resource "azurerm_subnet" "gateway" {
  name                 = "GatewaySubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.gateway_subnet_cidr]
}

# AzureFirewallSubnet — for Azure Firewall
# Cannot have NSG attached, minimum /26
resource "azurerm_subnet" "firewall" {
  name                 = "AzureFirewallSubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.firewall_subnet_cidr]
}

# AzureBastionSubnet — for Azure Bastion
# Cannot have NSG attached
resource "azurerm_subnet" "bastion" {
  name                 = "AzureBastionSubnet"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.bastion_subnet_cidr]
}

# Management subnet — for jumpboxes, monitoring agents
# NSG allowed here
resource "azurerm_subnet" "management" {
  name                 = "snet-management"
  resource_group_name  = azurerm_resource_group.hub.name
  virtual_network_name = azurerm_virtual_network.hub.name
  address_prefixes     = [var.management_subnet_cidr]
}

# -----------------------------------------------
# NSG — management subnet only
# Gateway, Firewall, Bastion subnets cannot have NSGs
# -----------------------------------------------
resource "azurerm_network_security_group" "management" {
  name                = "nsg-management"
  location            = azurerm_resource_group.hub.location
  resource_group_name = azurerm_resource_group.hub.name
  tags                = var.tags

  # Deny all inbound by default — Azure implicit rule
  # Only add explicit allows below

  security_rule {
    name                       = "deny-inbound-internet"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow-vnet-inbound"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "VirtualNetwork"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "management" {
  subnet_id                 = azurerm_subnet.management.id
  network_security_group_id = azurerm_network_security_group.management.id
}

# -----------------------------------------------
# PRIVATE DNS ZONE
# Linked to hub — spokes resolve via hub
# -----------------------------------------------
resource "azurerm_private_dns_zone" "hub" {
  name                = "privatelink.azure.com"
  resource_group_name = azurerm_resource_group.hub.name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "hub" {
  name                  = "hub-dns-link"
  resource_group_name   = azurerm_resource_group.hub.name
  private_dns_zone_name = azurerm_private_dns_zone.hub.name
  virtual_network_id    = azurerm_virtual_network.hub.id
  registration_enabled  = false
  tags                  = var.tags
}

# -----------------------------------------------
# ROUTE TABLE — placeholder for firewall routing
# UDRs will point to firewall private IP when
# Azure Firewall is deployed on paid subscription
# -----------------------------------------------
resource "azurerm_route_table" "hub" {
  name                          = "rt-hub"
  location                      = azurerm_resource_group.hub.location
  resource_group_name           = azurerm_resource_group.hub.name
  bgp_route_propagation_enabled = false
  tags                          = var.tags
}
# -----------------------------------------------
# RESOURCE GROUP
# -----------------------------------------------
resource "azurerm_resource_group" "spoke" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# -----------------------------------------------
# SPOKE VNET
# -----------------------------------------------
resource "azurerm_virtual_network" "spoke" {
  name                = "vnet-spoke-${var.spoke_name}"
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
  address_space       = [var.vnet_cidr]
  tags                = var.tags
}

# -----------------------------------------------
# SUBNETS
# -----------------------------------------------
resource "azurerm_subnet" "app" {
  name                 = "snet-app-${var.spoke_name}"
  resource_group_name  = azurerm_resource_group.spoke.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [var.app_subnet_cidr]
}

resource "azurerm_subnet" "data" {
  name                 = "snet-data-${var.spoke_name}"
  resource_group_name  = azurerm_resource_group.spoke.name
  virtual_network_name = azurerm_virtual_network.spoke.name
  address_prefixes     = [var.data_subnet_cidr]
}

# -----------------------------------------------
# NSG — APP SUBNET
# -----------------------------------------------
resource "azurerm_network_security_group" "app" {
  name                = "nsg-app-${var.spoke_name}"
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
  tags                = var.tags

  security_rule {
    name                       = "deny-internet-inbound"
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

  security_rule {
    name                       = "allow-https-outbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }
}

resource "azurerm_subnet_network_security_group_association" "app" {
  subnet_id                 = azurerm_subnet.app.id
  network_security_group_id = azurerm_network_security_group.app.id
}

# -----------------------------------------------
# NSG — DATA SUBNET
# Stricter than app — no direct internet outbound
# -----------------------------------------------
resource "azurerm_network_security_group" "data" {
  name                = "nsg-data-${var.spoke_name}"
  location            = azurerm_resource_group.spoke.location
  resource_group_name = azurerm_resource_group.spoke.name
  tags                = var.tags

  security_rule {
    name                       = "deny-internet-inbound"
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
    name                       = "allow-app-subnet-inbound"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = var.app_subnet_cidr
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "deny-internet-outbound"
    priority                   = 100
    direction                  = "Outbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "Internet"
  }
}

resource "azurerm_subnet_network_security_group_association" "data" {
  subnet_id                 = azurerm_subnet.data.id
  network_security_group_id = azurerm_network_security_group.data.id
}

# -----------------------------------------------
# UDR — ROUTE ALL TRAFFIC THROUGH HUB
# Points to hub route table
# When firewall is deployed, add next hop = firewall IP
# -----------------------------------------------
resource "azurerm_subnet_route_table_association" "app" {
  subnet_id      = azurerm_subnet.app.id
  route_table_id = var.route_table_id
}

resource "azurerm_subnet_route_table_association" "data" {
  subnet_id      = azurerm_subnet.data.id
  route_table_id = var.route_table_id
}

# -----------------------------------------------
# VNET PEERING — SPOKE TO HUB
# Both directions required — Azure peering is not transitive
# -----------------------------------------------
resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "peer-${var.spoke_name}-to-hub"
  resource_group_name       = azurerm_resource_group.spoke.name
  virtual_network_name      = azurerm_virtual_network.spoke.name
  remote_virtual_network_id = var.hub_vnet_id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "peer-hub-to-${var.spoke_name}"
  resource_group_name       = var.hub_resource_group_name
  virtual_network_name      = var.hub_vnet_name
  remote_virtual_network_id = azurerm_virtual_network.spoke.id

  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  use_remote_gateways          = false
}

# -----------------------------------------------
# PRIVATE DNS ZONE LINK
# Links spoke to hub DNS zone for private endpoint resolution
# -----------------------------------------------
resource "azurerm_private_dns_zone_virtual_network_link" "spoke" {
  name                  = "link-${var.spoke_name}"
  resource_group_name   = var.hub_resource_group_name
  private_dns_zone_name = "privatelink.azure.com"
  virtual_network_id    = azurerm_virtual_network.spoke.id
  registration_enabled  = false
  tags                  = var.tags
}

# -----------------------------------------------
# SPOKE — DEV
# -----------------------------------------------
module "spoke_dev" {
  source = "./modules/spoke"

  spoke_name              = "dev"
  resource_group_name     = "rg-spoke-dev"
  location                = var.location
  vnet_cidr               = "10.1.0.0/16"
  app_subnet_cidr         = "10.1.1.0/24"
  data_subnet_cidr        = "10.1.2.0/24"
  hub_vnet_id             = module.hub.hub_vnet_id
  hub_vnet_name           = module.hub.hub_vnet_name
  hub_resource_group_name = module.hub.resource_group_name
  route_table_id          = module.hub.route_table_id
  tags                    = var.tags

  depends_on = [module.hub]
}

# -----------------------------------------------
# SPOKE — PROD
# -----------------------------------------------
module "spoke_prod" {
  source = "./modules/spoke"

  spoke_name              = "prod"
  resource_group_name     = "rg-spoke-prod"
  location                = var.location
  vnet_cidr               = "10.3.0.0/16"
  app_subnet_cidr         = "10.3.1.0/24"
  data_subnet_cidr        = "10.3.2.0/24"
  hub_vnet_id             = module.hub.hub_vnet_id
  hub_vnet_name           = module.hub.hub_vnet_name
  hub_resource_group_name = module.hub.resource_group_name
  route_table_id          = module.hub.route_table_id
  tags                    = var.tags

  depends_on = [module.hub]
}
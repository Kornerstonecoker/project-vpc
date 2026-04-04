

# Get the tenant root management group ID
data "azurerm_management_group" "root" {
  name = data.azurerm_client_config.current.tenant_id
}

data "azurerm_client_config" "current" {}

module "management_groups" {
  source = "./modules/management-groups"

  root_management_group_id = data.azurerm_management_group.root.id
  prefix                   = "mg"

  tags = {
    project    = "project-vpc"
    managed_by = "terraform"
    owner      = "kornerstonecoker"
  }
}

resource "azurerm_resource_group" "hub" {
  name     = "rg-connectivity-hub"
  location = var.location
  tags     = var.tags
}

module "hub" {
  source = "./modules/hub"

  resource_group_name    = "rg-connectivity-hub"
  location               = var.location
  hub_vnet_cidr          = "10.0.0.0/16"
  gateway_subnet_cidr    = "10.0.0.0/27"
  firewall_subnet_cidr   = "10.0.1.0/26"
  bastion_subnet_cidr    = "10.0.2.0/27"
  management_subnet_cidr = "10.0.3.0/24"
  tags                   = var.tags

  depends_on = [module.management_groups]
}

# -----------------------------------------------
# DEFENDER FOR CLOUD
# -----------------------------------------------
module "defender" {
  source = "./modules/defender"

  location               = var.location
  security_contact_email = "kornerstonecoker@gmail.com"
  tags                   = var.tags

  depends_on = [module.management_groups]
}
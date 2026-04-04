

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

# -----------------------------------------------
# KEY VAULT + MANAGED IDENTITY — DEV SPOKE
# -----------------------------------------------
module "keyvault_dev" {
  source = "./modules/keyvault"

  resource_group_name        = "rg-keyvault-dev"
  location                   = var.location
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  admin_object_id            = data.azurerm_client_config.current.object_id
  spoke_name                 = "dev"
  log_analytics_workspace_id = module.defender.log_analytics_workspace_id
  tags                       = var.tags

  depends_on = [module.defender]
}
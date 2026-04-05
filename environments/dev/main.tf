data "azurerm_client_config" "current" {}

# -----------------------------------------------
# SPOKE VNET
# -----------------------------------------------
module "spoke" {
  source = "../../modules/spoke"

  spoke_name              = var.environment
  resource_group_name     = "rg-spoke-${var.environment}"
  location                = var.location
  vnet_cidr               = var.vnet_cidr
  app_subnet_cidr         = var.app_subnet_cidr
  data_subnet_cidr        = var.data_subnet_cidr
  hub_vnet_id             = var.hub_vnet_id
  hub_vnet_name           = var.hub_vnet_name
  hub_resource_group_name = var.hub_resource_group_name
  route_table_id          = var.route_table_id
  tags                    = var.tags
}

# -----------------------------------------------
# KEY VAULT + MANAGED IDENTITY
# -----------------------------------------------
module "keyvault" {
  source = "../../modules/keyvault"

  resource_group_name        = "rg-keyvault-${var.environment}"
  location                   = var.location
  tenant_id                  = var.tenant_id
  admin_object_id            = var.admin_object_id
  spoke_name                 = var.environment
  log_analytics_workspace_id = var.log_analytics_workspace_id
  tags                       = var.tags

  depends_on = [module.spoke]
}
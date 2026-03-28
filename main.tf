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
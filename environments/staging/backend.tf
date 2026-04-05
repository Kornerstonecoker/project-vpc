terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstateiii50i"
    container_name       = "tfstate"
    key                  = "environments/staging/terraform.tfstate"
    use_azuread_auth     = true
  }
}
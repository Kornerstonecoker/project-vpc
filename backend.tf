terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "stterraformstateXXXXXX" # paste output value here
    container_name       = "tfstate"
    key                  = "hub-spoke/terraform.tfstate"
    use_azuread_auth     = true # use Entra ID, not storage key
  }
}
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  storage_use_azuread = true
}

resource "azurerm_resource_group" "tfstate" {
  name     = "rg-terraform-state"
  location = "northeurope"
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "stterraformstate${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  # security hardening
  allow_nested_items_to_be_public = false
  shared_access_key_enabled       = false
  min_tls_version                 = "TLS1_2"
  public_network_access_enabled   = false

  blob_properties {
    versioning_enabled = true

    delete_retention_policy {
      days = 30
    }

    logging {
      delete                = true
      read                  = true
      write                 = true
      version               = "1.0"
      retention_policy_days = 30
    }
  }

  queue_properties {
    logging {
      delete                = true
      read                  = true
      write                 = true
      version               = "1.0"
      retention_policy_days = 30
    }
  }

  #checkov:skip=CKV_AZURE_206:LRS acceptable for non-production state storage
  #checkov:skip=CKV2_AZURE_33:Private endpoint added when hub VNet is deployed
  #checkov:skip=CKV2_AZURE_1:CMK not required for learning environment
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"

  #checkov:skip=CKV2_AZURE_21:Blob logging configured at storage account level
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}
# -----------------------------------------------
# LOG ANALYTICS WORKSPACE
# Central store for Defender data and logs
# -----------------------------------------------
resource "azurerm_resource_group" "defender" {
  name     = "rg-security-defender"
  location = var.location
  tags     = var.tags
}

resource "azurerm_log_analytics_workspace" "defender" {
  name                = "law-defender-${random_string.suffix.result}"
  location            = azurerm_resource_group.defender.location
  resource_group_name = azurerm_resource_group.defender.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# -----------------------------------------------
# DEFENDER FOR CLOUD — FREE TIER PLANS
# Enables CSPM posture management
# Paid plans (~$15/resource/month) deferred to
# paid subscription
# -----------------------------------------------

resource "azurerm_security_center_subscription_pricing" "defender_servers" {
  tier          = "Free"
  resource_type = "VirtualMachines"
  #checkov:skip=CKV_AZURE_19:Free tier used on free trial - Standard enabled on paid subscription
  #checkov:skip=CKV_AZURE_55:Free tier used on free trial - Standard enabled on paid subscription
}

resource "azurerm_security_center_subscription_pricing" "defender_storage" {
  tier          = "Free"
  resource_type = "StorageAccounts"
  #checkov:skip=CKV_AZURE_19:Free tier used on free trial - Standard enabled on paid subscription
  #checkov:skip=CKV_AZURE_84:Free tier used on free trial - Standard enabled on paid subscription
}

resource "azurerm_security_center_subscription_pricing" "defender_keyvault" {
  tier          = "Free"
  resource_type = "KeyVaults"
  #checkov:skip=CKV_AZURE_19:Free tier used on free trial - Standard enabled on paid subscription
  #checkov:skip=CKV_AZURE_87:Free tier used on free trial - Standard enabled on paid subscription
}

resource "azurerm_security_center_subscription_pricing" "defender_arm" {
  tier          = "Free"
  resource_type = "Arm"
  #checkov:skip=CKV_AZURE_19:Free tier used on free trial - Standard enabled on paid subscription
  #checkov:skip=CKV_AZURE_234:Free tier used on free trial - Standard enabled on paid subscription
}

resource "azurerm_security_center_subscription_pricing" "defender_dns" {
  tier          = "Free"
  resource_type = "Dns"
  #checkov:skip=CKV_AZURE_19:Free tier used on free trial - Standard enabled on paid subscription
}

# -----------------------------------------------
# SECURITY CONTACT
# Who gets notified when Defender fires an alert
# -----------------------------------------------
resource "azurerm_security_center_contact" "main" {
  name  = "security-contact"
  email = var.security_contact_email
  # phone = var.security_contact_phone

  alert_notifications = true
  alerts_to_admins    = true
  #checkov:skip=CKV_AZURE_20:Phone number optional for learning environment
}

# -----------------------------------------------
# AUTO PROVISIONING
# Automatically installs monitoring agent on VMs
# -----------------------------------------------
resource "azurerm_security_center_auto_provisioning" "main" {
  auto_provision = "On"
}

# -----------------------------------------------
# DEFENDER WORKSPACE SETTING
# Points Defender data to our Log Analytics workspace
# -----------------------------------------------
resource "azurerm_security_center_workspace" "main" {
  scope        = "/subscriptions/${data.azurerm_client_config.current.subscription_id}"
  workspace_id = azurerm_log_analytics_workspace.defender.id
}

data "azurerm_client_config" "current" {}
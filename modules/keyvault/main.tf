# -----------------------------------------------
# RESOURCE GROUP
# -----------------------------------------------
resource "azurerm_resource_group" "keyvault" {
  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

# -----------------------------------------------
# KEY VAULT
# -----------------------------------------------
resource "azurerm_key_vault" "main" {
  name                = "kv-${var.spoke_name}-${random_string.suffix.result}"
  location            = azurerm_resource_group.keyvault.location
  resource_group_name = azurerm_resource_group.keyvault.name
  tenant_id           = var.tenant_id
  sku_name            = "standard"

  enable_rbac_authorization     = true
  purge_protection_enabled      = true
  soft_delete_retention_days    = 30
  public_network_access_enabled = false

  network_acls {
    default_action = "Deny"
    bypass         = "AzureServices"
  }

  tags = var.tags

  #checkov:skip=CKV2_AZURE_32:Private endpoint deferred - public access disabled and network ACL deny-all configured
}

resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# -----------------------------------------------
# MANAGED IDENTITY
# Used by workloads to authenticate to Key Vault
# No passwords — Azure manages the credential
# -----------------------------------------------
resource "azurerm_user_assigned_identity" "workload" {
  name                = "id-${var.spoke_name}-workload"
  location            = azurerm_resource_group.keyvault.location
  resource_group_name = azurerm_resource_group.keyvault.name
  tags                = var.tags
}

# -----------------------------------------------
# RBAC — Key Vault Secrets User for managed identity
# Allows the workload to READ secrets only
# Cannot create, update or delete secrets
# -----------------------------------------------
resource "azurerm_role_assignment" "workload_secrets_user" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.workload.principal_id
}

# -----------------------------------------------
# RBAC — Key Vault Administrator for platform admin
# Full access for the team managing secrets
# -----------------------------------------------
resource "azurerm_role_assignment" "admin_keyvault" {
  scope                = azurerm_key_vault.main.id
  role_definition_name = "Key Vault Administrator"
  principal_id         = var.admin_object_id
}

# -----------------------------------------------
# DIAGNOSTIC SETTINGS
# Every read/write/delete on Key Vault logged
# to Log Analytics — full audit trail
# -----------------------------------------------
resource "azurerm_monitor_diagnostic_setting" "keyvault" {
  name                       = "diag-${var.spoke_name}-keyvault"
  target_resource_id         = azurerm_key_vault.main.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AuditEvent"
  }

  enabled_log {
    category = "AzurePolicyEvaluationDetails"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}
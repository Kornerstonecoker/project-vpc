output "key_vault_id" {
  description = "Key Vault resource ID"
  value       = azurerm_key_vault.main.id
}

output "key_vault_name" {
  description = "Key Vault name"
  value       = azurerm_key_vault.main.name
}

output "key_vault_uri" {
  description = "Key Vault URI for secret references"
  value       = azurerm_key_vault.main.vault_uri
}

output "managed_identity_id" {
  description = "Managed identity resource ID"
  value       = azurerm_user_assigned_identity.workload.id
}

output "managed_identity_client_id" {
  description = "Managed identity client ID — used in app config"
  value       = azurerm_user_assigned_identity.workload.client_id
}

output "managed_identity_principal_id" {
  description = "Managed identity principal ID — used for RBAC"
  value       = azurerm_user_assigned_identity.workload.principal_id
}

output "resource_group_name" {
  description = "Key Vault resource group name"
  value       = azurerm_resource_group.keyvault.name
}
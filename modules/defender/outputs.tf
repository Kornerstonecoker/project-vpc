output "log_analytics_workspace_id" {
  description = "Log Analytics workspace ID"
  value       = azurerm_log_analytics_workspace.defender.id
}

output "log_analytics_workspace_name" {
  description = "Log Analytics workspace name"
  value       = azurerm_log_analytics_workspace.defender.name
}

output "resource_group_name" {
  description = "Defender resource group name"
  value       = azurerm_resource_group.defender.name
}
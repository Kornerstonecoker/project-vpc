output "platform_id" {
  description = "Platform management group ID"
  value       = azurerm_management_group.platform.id
}

output "connectivity_id" {
  description = "Connectivity management group ID"
  value       = azurerm_management_group.connectivity.id
}

output "identity_id" {
  description = "Identity management group ID"
  value       = azurerm_management_group.identity.id
}

output "management_id" {
  description = "Management management group ID"
  value       = azurerm_management_group.management.id
}

output "security_id" {
  description = "Security management group ID"
  value       = azurerm_management_group.security.id
}

output "landingzones_id" {
  description = "Landing zones management group ID"
  value       = azurerm_management_group.landingzones.id
}

output "corp_id" {
  description = "Corp management group ID"
  value       = azurerm_management_group.corp.id
}

output "online_id" {
  description = "Online management group ID"
  value       = azurerm_management_group.online.id
}

output "sandbox_id" {
  description = "Sandbox management group ID"
  value       = azurerm_management_group.sandbox.id
}

output "decommissioned_id" {
  description = "Decommissioned management group ID"
  value       = azurerm_management_group.decommissioned.id
}
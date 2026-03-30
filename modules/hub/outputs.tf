output "hub_vnet_id" {
  description = "Hub VNet ID — used by peering module"
  value       = azurerm_virtual_network.hub.id
}

output "hub_vnet_name" {
  description = "Hub VNet name — used by peering module"
  value       = azurerm_virtual_network.hub.name
}

output "resource_group_name" {
  description = "Hub resource group name"
  value       = azurerm_resource_group.hub.name
}

output "gateway_subnet_id" {
  description = "GatewaySubnet ID"
  value       = azurerm_subnet.gateway.id
}

output "firewall_subnet_id" {
  description = "AzureFirewallSubnet ID — firewall deploys here"
  value       = azurerm_subnet.firewall.id
}

output "bastion_subnet_id" {
  description = "AzureBastionSubnet ID"
  value       = azurerm_subnet.bastion.id
}

output "management_subnet_id" {
  description = "Management subnet ID"
  value       = azurerm_subnet.management.id
}

output "route_table_id" {
  description = "Hub route table ID — associated with spoke subnets via UDRs"
  value       = azurerm_route_table.hub.id
}

output "private_dns_zone_id" {
  description = "Private DNS zone ID"
  value       = azurerm_private_dns_zone.hub.id
}
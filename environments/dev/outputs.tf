output "spoke_vnet_id" {
  value = module.spoke.spoke_vnet_id
}

output "key_vault_name" {
  value = module.keyvault.key_vault_name
}

output "managed_identity_id" {
  value = module.keyvault.managed_identity_id
}
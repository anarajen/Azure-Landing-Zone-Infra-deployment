output "resource_group_name" {
  value = module.state_rg.name
}

output "storage_account_name" {
  value = module.state_storage.name
}

output "container_name" {
  value = "tfstate"
}

output "security_resource_group_name" {
  value = module.security_rg.name
}

output "key_vault_name" {
  value = module.key_vault.name
}

output "key_vault_id" {
  value = module.key_vault.id
}

output "key_vault_uri" {
  value = module.key_vault.vault_uri
}
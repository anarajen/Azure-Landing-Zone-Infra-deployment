variable "name" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "tenant_id" {
  type = string
}
variable "sku_name" {
  type = string
  default = "standard"
}
variable "public_network_access_enabled" {
  type = bool
  default = true
}
variable "network_default_action" {
  type = string
  default = "Allow"
}
variable "bypass" {
  type = string
  default = "AzureServices"
}
variable "tags" {
  type = map(string)
  default = {}
}
resource "azurerm_key_vault" "this" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  tenant_id                     = var.tenant_id
  sku_name                      = var.sku_name
  rbac_authorization_enabled    = true
  soft_delete_retention_days    = 90
  purge_protection_enabled      = true
  public_network_access_enabled = var.public_network_access_enabled
  tags                          = var.tags

  network_acls {
    bypass         = var.bypass
    default_action = var.network_default_action
  }
}
output "id" {
  value = azurerm_key_vault.this.id
}
output "name" {
  value = azurerm_key_vault.this.name
}
output "vault_uri" {
  value = azurerm_key_vault.this.vault_uri
}

variable "name" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "sku" {
  type = string
  default = "Standard"
}
variable "storage_mode_type" {
  type = string
  default = "LocallyRedundant"
}
variable "public_network_access_enabled" {
  type = bool
  default = true
}
variable "tags" {
  type = map(string)
  default = {}
}
resource "azurerm_recovery_services_vault" "this" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = var.sku
  storage_mode_type             = var.storage_mode_type
  soft_delete_enabled           = true
  public_network_access_enabled = var.public_network_access_enabled
  tags                          = var.tags
}
output "id" {
  value = azurerm_recovery_services_vault.this.id
}
output "name" {
  value = azurerm_recovery_services_vault.this.name
}

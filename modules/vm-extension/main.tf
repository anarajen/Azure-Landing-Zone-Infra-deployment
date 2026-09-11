variable "name" {
  type = string
}
variable "virtual_machine_id" {
  type = string
}
variable "publisher" {
  type = string
}
variable "type" {
  type = string
}
variable "type_handler_version" {
  type = string
}
variable "auto_upgrade_minor_version" {
  type = bool
  default = true
}
variable "automatic_upgrade_enabled" {
  type = bool
  default = true
}
variable "settings" {
  type = string
  default = null
}
variable "protected_settings" {
  type = string
  default = null
  sensitive = true
}
variable "tags" {
  type = map(string)
  default = {}
}
resource "azurerm_virtual_machine_extension" "this" {
  name                       = var.name
  virtual_machine_id         = var.virtual_machine_id
  publisher                  = var.publisher
  type                       = var.type
  type_handler_version       = var.type_handler_version
  auto_upgrade_minor_version = var.auto_upgrade_minor_version
  automatic_upgrade_enabled  = var.automatic_upgrade_enabled
  settings                   = var.settings
  protected_settings         = var.protected_settings
  tags                       = var.tags
}
output "id" {
  value = azurerm_virtual_machine_extension.this.id
}

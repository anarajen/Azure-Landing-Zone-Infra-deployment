variable "name" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "private_dns_zone_name" {
  type = string
}
variable "virtual_network_id" {
  type = string
}
variable "registration_enabled" {
  type = bool
  default = false
}
variable "tags" {
  type = map(string)
  default = {}
}
resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  name                  = var.name
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = var.private_dns_zone_name
  virtual_network_id    = var.virtual_network_id
  registration_enabled  = var.registration_enabled
  tags                  = var.tags
}
output "id" {
  value = azurerm_private_dns_zone_virtual_network_link.this.id
}

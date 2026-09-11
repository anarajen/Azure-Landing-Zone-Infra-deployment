variable "name" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "tags" {
  type = map(string)
  default = {}
}
resource "azurerm_private_dns_zone" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}
output "id" {
  value = azurerm_private_dns_zone.this.id
}
output "name" {
  value = azurerm_private_dns_zone.this.name
}

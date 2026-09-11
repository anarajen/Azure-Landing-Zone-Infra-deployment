variable "name" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "address_space" {
  type = list(string)
}
variable "dns_servers" {
  type = list(string)
  default = []
}
variable "tags" {
  type = map(string)
  default = {}
}
resource "azurerm_virtual_network" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  address_space       = var.address_space
  dns_servers         = var.dns_servers
  tags                = var.tags
}
output "id" {
  value = azurerm_virtual_network.this.id
}
output "name" {
  value = azurerm_virtual_network.this.name
}

variable "name" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "public_ip_address_id" {
  type = string
}
variable "idle_timeout_in_minutes" {
  type = number
  default = 4
}
variable "zones" {
  type = list(string)
  default = null
}
variable "tags" {
  type = map(string)
  default = {}
}
resource "azurerm_nat_gateway" "this" {
  name                    = var.name
  resource_group_name     = var.resource_group_name
  location                = var.location
  sku_name                = "Standard"
  idle_timeout_in_minutes = var.idle_timeout_in_minutes
  zones                   = var.zones
  tags                    = var.tags
}
resource "azurerm_nat_gateway_public_ip_association" "this" {
  nat_gateway_id       = azurerm_nat_gateway.this.id
  public_ip_address_id = var.public_ip_address_id
}
output "id" {
  value = azurerm_nat_gateway.this.id
}
output "name" {
  value = azurerm_nat_gateway.this.name
}

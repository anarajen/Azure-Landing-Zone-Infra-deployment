variable "name" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "allocation_method" {
  type = string
  default = "Static"
}
variable "sku" {
  type = string
  default = "Standard"
}
variable "ip_version" {
  type = string
  default = "IPv4"
}
variable "zones" {
  type = list(string)
  default = null
}
variable "domain_name_label" {
  type    = string
  default = null
}
variable "ddos_protection_mode" {
  type    = string
  default = null
}
variable "tags" {
  type = map(string)
  default = {}
}
resource "azurerm_public_ip" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = var.allocation_method
  sku                 = var.sku
  ip_version          = var.ip_version
  zones               = var.zones
  domain_name_label    = var.domain_name_label
  ddos_protection_mode = var.ddos_protection_mode
  tags                 = var.tags
}
output "id" {
  value = azurerm_public_ip.this.id
}
output "ip_address" {
  value = azurerm_public_ip.this.ip_address
}
output "name" {
  value = azurerm_public_ip.this.name
}

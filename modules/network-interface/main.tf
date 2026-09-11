variable "name" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "subnet_id" {
  type = string
}
variable "private_ip_address" {
  type = string
}
variable "accelerated_networking_enabled" {
  type = bool
  default = false
}
variable "ip_forwarding_enabled" {
  type = bool
  default = false
}
variable "dns_servers" {
  type = list(string)
  default = []
}
variable "tags" {
  type = map(string)
  default = {}
}
resource "azurerm_network_interface" "this" {
  name                           = var.name
  resource_group_name            = var.resource_group_name
  location                       = var.location
  accelerated_networking_enabled = var.accelerated_networking_enabled
  ip_forwarding_enabled          = var.ip_forwarding_enabled
  dns_servers                    = var.dns_servers
  tags                           = var.tags
  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Static"
    private_ip_address            = var.private_ip_address
    primary                       = true
  }
}
output "id" {
  value = azurerm_network_interface.this.id
}
output "private_ip_address" {
  value = azurerm_network_interface.this.private_ip_address
}

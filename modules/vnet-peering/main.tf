variable "name" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "virtual_network_name" {
  type = string
}
variable "remote_virtual_network_id" {
  type = string
}
variable "allow_virtual_network_access" {
  type = bool
  default = true
}
variable "allow_forwarded_traffic" {
  type = bool
  default = false
}
variable "allow_gateway_transit" {
  type = bool
  default = false
}
variable "use_remote_gateways" {
  type = bool
  default = false
}
resource "azurerm_virtual_network_peering" "this" {
  name                      = var.name
  resource_group_name       = var.resource_group_name
  virtual_network_name      = var.virtual_network_name
  remote_virtual_network_id = var.remote_virtual_network_id
  allow_virtual_network_access = var.allow_virtual_network_access
  allow_forwarded_traffic      = var.allow_forwarded_traffic
  allow_gateway_transit        = var.allow_gateway_transit
  use_remote_gateways          = var.use_remote_gateways
}
output "id" {
  value = azurerm_virtual_network_peering.this.id
}

variable "name" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "gateway_address" {
  type = string
}
variable "address_space" {
  type = list(string)
}
variable "bgp_settings" {
  type = any
  default = null
}
variable "tags" {
  type = map(string)
  default = {}
}
resource "azurerm_local_network_gateway" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  gateway_address     = var.gateway_address
  address_space       = var.address_space
  tags                = var.tags

  dynamic "bgp_settings" {
    for_each = var.bgp_settings == null ? [] : [var.bgp_settings]
    content {
      asn                 = bgp_settings.value.asn
      bgp_peering_address = bgp_settings.value.bgp_peering_address
      peer_weight         = try(bgp_settings.value.peer_weight, 0)
    }
  }
}
output "id" {
  value = azurerm_local_network_gateway.this.id
}

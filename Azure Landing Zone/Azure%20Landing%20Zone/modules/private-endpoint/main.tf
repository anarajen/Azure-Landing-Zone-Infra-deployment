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
variable "custom_network_interface_name" {
  type = string
  default = null
}
variable "connection_name" {
  type = string
}
variable "private_connection_resource_id" {
  type = string
}
variable "subresource_names" {
  type = list(string)
}
variable "private_dns_zone_group_name" {
  type = string
  default = null
}
variable "private_dns_zone_ids" {
  type = list(string)
  default = []
}
variable "is_manual_connection" {
  type = bool
  default = false
}
variable "tags" {
  type = map(string)
  default = {}
}
resource "azurerm_private_endpoint" "this" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  subnet_id                     = var.subnet_id
  custom_network_interface_name = var.custom_network_interface_name
  tags                          = var.tags

  private_service_connection {
    name                           = var.connection_name
    private_connection_resource_id = var.private_connection_resource_id
    subresource_names              = var.subresource_names
    is_manual_connection           = var.is_manual_connection
  }

  dynamic "private_dns_zone_group" {
    for_each = length(var.private_dns_zone_ids) > 0 ? [1] : []
    content {
      name                 = var.private_dns_zone_group_name
      private_dns_zone_ids = var.private_dns_zone_ids
    }
  }
}
output "id" {
  value = azurerm_private_endpoint.this.id
}
output "network_interface" {
  value = azurerm_private_endpoint.this.network_interface
}

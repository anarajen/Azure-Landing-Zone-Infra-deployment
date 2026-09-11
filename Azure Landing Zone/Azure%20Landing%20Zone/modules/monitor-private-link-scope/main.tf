variable "name" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "ingestion_access_mode" {
  type = string
  default = "Open"
}
variable "query_access_mode" {
  type = string
  default = "Open"
}
variable "scoped_services" {
  type = map(string)
  default = {}
}
variable "tags" {
  type = map(string)
  default = {}
}
resource "azurerm_monitor_private_link_scope" "this" {
  name                  = var.name
  resource_group_name   = var.resource_group_name
  ingestion_access_mode = var.ingestion_access_mode
  query_access_mode     = var.query_access_mode
  tags                  = var.tags
}
resource "azurerm_monitor_private_link_scoped_service" "this" {
  for_each            = var.scoped_services
  name                = each.key
  resource_group_name = var.resource_group_name
  scope_name          = azurerm_monitor_private_link_scope.this.name
  linked_resource_id  = each.value
}
output "id" {
  value = azurerm_monitor_private_link_scope.this.id
}
output "name" {
  value = azurerm_monitor_private_link_scope.this.name
}

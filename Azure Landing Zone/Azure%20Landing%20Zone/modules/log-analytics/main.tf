variable "name" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "sku" {
  type = string
  default = "PerGB2018"
}
variable "retention_in_days" {
  type = number
  default = 90
}
variable "internet_ingestion_enabled" {
  type = bool
  default = true
}
variable "internet_query_enabled" {
  type = bool
  default = true
}
variable "tags" {
  type = map(string)
  default = {}
}
resource "azurerm_log_analytics_workspace" "this" {
  name                       = var.name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  sku                        = var.sku
  retention_in_days          = var.retention_in_days
  internet_ingestion_enabled = var.internet_ingestion_enabled
  internet_query_enabled     = var.internet_query_enabled
  tags                       = var.tags
}
output "id" {
  value = azurerm_log_analytics_workspace.this.id
}
output "workspace_id" {
  value = azurerm_log_analytics_workspace.this.workspace_id
}
output "name" {
  value = azurerm_log_analytics_workspace.this.name
}

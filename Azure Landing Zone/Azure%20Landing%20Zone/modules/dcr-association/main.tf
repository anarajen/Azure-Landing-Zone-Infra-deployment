variable "name" {
  type = string
}
variable "target_resource_id" {
  type = string
}
variable "data_collection_rule_id" {
  type = string
}
resource "azurerm_monitor_data_collection_rule_association" "this" {
  name                    = var.name
  target_resource_id      = var.target_resource_id
  data_collection_rule_id = var.data_collection_rule_id
}

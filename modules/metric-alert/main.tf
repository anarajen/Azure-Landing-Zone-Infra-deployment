variable "name" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "scopes" {
  type = list(string)
}
variable "description" {
  type = string
  default = null
}
variable "severity" {
  type = number
  default = 2
}
variable "frequency" {
  type = string
  default = "PT5M"
}
variable "window_size" {
  type = string
  default = "PT15M"
}
variable "target_resource_type" {
  type = string
  default = null
}
variable "target_resource_location" {
  type = string
  default = null
}
variable "criteria" {
  type = any
}
variable "action_group_id" {
  type = string
}
variable "tags" {
  type = map(string)
  default = {}
}
resource "azurerm_monitor_metric_alert" "this" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  scopes                   = var.scopes
  description              = var.description
  severity                 = var.severity
  frequency                = var.frequency
  window_size              = var.window_size
  target_resource_type     = var.target_resource_type
  target_resource_location = var.target_resource_location
  enabled                  = true
  auto_mitigate            = true
  tags                     = var.tags

  criteria {
    metric_namespace = var.criteria.metric_namespace
    metric_name      = var.criteria.metric_name
    aggregation      = var.criteria.aggregation
    operator         = var.criteria.operator
    threshold        = var.criteria.threshold
  }

  action { action_group_id = var.action_group_id }
}

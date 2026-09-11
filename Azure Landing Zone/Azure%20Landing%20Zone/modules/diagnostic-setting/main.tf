variable "name" {
  type = string
}
variable "target_resource_id" {
  type = string
}
variable "log_analytics_workspace_id" {
  type = string
}
variable "log_categories" {
  type = list(string)
  default = []
}
variable "metric_categories" {
  type = list(string)
  default = ["AllMetrics"]
}
resource "azurerm_monitor_diagnostic_setting" "this" {
  name                       = var.name
  target_resource_id         = var.target_resource_id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  log_analytics_destination_type = "Dedicated"
  dynamic "enabled_log" {
    for_each = toset(var.log_categories)
    content { category = enabled_log.value }
  }
  dynamic "enabled_metric" {
    for_each = toset(var.metric_categories)
    content { category = enabled_metric.value }
  }
   lifecycle {
    ignore_changes = [
      log_analytics_destination_type,
    ]
  }
}

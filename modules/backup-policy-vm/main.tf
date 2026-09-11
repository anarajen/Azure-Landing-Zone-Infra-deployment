variable "name" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "recovery_vault_name" {
  type = string
}
variable "timezone" {
  type = string
}
variable "backup_time" {
  type = string
}
variable "retention_daily_count" {
  type = number
}
resource "azurerm_backup_policy_vm" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  recovery_vault_name = var.recovery_vault_name
  timezone            = var.timezone
  policy_type         = "V2"
  backup {
    frequency = "Daily"
    time      = var.backup_time
  }
  retention_daily { count = var.retention_daily_count }
}
output "id" {
  value = azurerm_backup_policy_vm.this.id
}

variable "location" {
  type = string
}
variable "maintenance_configuration_id" {
  type = string
}
variable "virtual_machine_id" {
  type = string
}
resource "azurerm_maintenance_assignment_virtual_machine" "this" {
  location                     = var.location
  maintenance_configuration_id = var.maintenance_configuration_id
  virtual_machine_id           = var.virtual_machine_id
}

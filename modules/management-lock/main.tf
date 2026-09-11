variable "name" {
  type = string
}
variable "scope" {
  type = string
}
variable "lock_level" {
  type = string
  default = "CanNotDelete"
}
variable "notes" {
  type = string
  default = null
}
resource "azurerm_management_lock" "this" {
  name       = var.name
  scope      = var.scope
  lock_level = var.lock_level
  notes      = var.notes
}

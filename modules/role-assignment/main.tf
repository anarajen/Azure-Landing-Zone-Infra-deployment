variable "scope" {
  type = string
}
variable "role_definition_name" {
  type = string
}
variable "principal_id" {
  type = string
}
variable "principal_type" {
  type = string
  default = null
}
resource "azurerm_role_assignment" "this" {
  scope                = var.scope
  role_definition_name = var.role_definition_name
  principal_id         = var.principal_id
  principal_type       = var.principal_type
}
output "id" {
  value = azurerm_role_assignment.this.id
}

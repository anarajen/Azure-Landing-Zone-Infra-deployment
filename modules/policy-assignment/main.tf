variable "name" {
  type = string
}
variable "display_name" {
  type = string
}
variable "policy_definition_id" {
  type = string
}
variable "subscription_id" {
  type = string
}
variable "parameters" {
  type = string
  default = null
}
variable "not_scopes" {
  type = list(string)
  default = []
}
resource "azurerm_subscription_policy_assignment" "this" {
  name                 = var.name
  display_name         = var.display_name
  policy_definition_id = var.policy_definition_id
  subscription_id      = var.subscription_id
  parameters           = var.parameters
  not_scopes           = var.not_scopes
}
output "id" {
  value = azurerm_subscription_policy_assignment.this.id
}

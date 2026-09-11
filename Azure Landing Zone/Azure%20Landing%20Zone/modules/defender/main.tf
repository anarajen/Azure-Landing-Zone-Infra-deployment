variable "resource_type" {
  type = string
  default = "VirtualMachines"
}
variable "tier" {
  type = string
  default = "Standard"
}
variable "subplan" {
  type = string
  default = null
}
resource "azurerm_security_center_subscription_pricing" "this" {
  tier          = var.tier
  resource_type = var.resource_type
  subplan       = var.subplan
}

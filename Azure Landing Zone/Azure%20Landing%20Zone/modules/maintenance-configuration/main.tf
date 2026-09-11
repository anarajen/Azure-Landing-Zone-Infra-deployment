variable "name" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "start_date_time" {
  type = string
}
variable "duration" {
  type = string
}
variable "time_zone" {
  type = string
}
variable "recur_every" {
  type = string
}
variable "reboot" {
  type = string
  default = "IfRequired"
}
variable "classifications_to_include" {
  type = list(string)
  default = ["Critical", "Security", "UpdateRollup", "Updates"]
}
variable "tags" {
  type = map(string)
  default = {}
}
resource "azurerm_maintenance_configuration" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  scope               = "InGuestPatch"
  in_guest_user_patch_mode = "User"
  tags                = var.tags
  window {
    start_date_time = var.start_date_time
    duration        = var.duration
    time_zone       = var.time_zone
    recur_every     = var.recur_every
  }
  install_patches {
    reboot = var.reboot
    windows {
      classifications_to_include = var.classifications_to_include
    }
  }
}
output "id" {
  value = azurerm_maintenance_configuration.this.id
}

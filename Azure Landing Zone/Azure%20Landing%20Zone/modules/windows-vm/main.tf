variable "name" {
  type = string
}

variable "computer_name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "size" {
  type = string
}

variable "admin_username" {
  type = string
}

variable "admin_password" {
  type      = string
  sensitive = true
}

variable "network_interface_ids" {
  type = list(string)
}

variable "source_image_id" {
  type = string
}

/*
variable "image_publisher" {
  type    = string
  default = "MicrosoftWindowsServer"
}
variable "image_offer" {
  type    = string
  default = "WindowsServer"
}
variable "image_sku" {
  type    = string
  default = "2025-datacenter-azure-edition"
}
variable "image_version" {
  type    = string
  default = "latest"
}
*/
variable "os_disk_name" {
  type = string
}

variable "os_disk_storage_account_type" {
  type = string
}

variable "os_disk_size_gb" {
  type = number
}

variable "os_disk_caching" {
  type    = string
  default = "ReadWrite"
}

variable "secure_boot_enabled" {
  type    = bool
  default = true
}

variable "vtpm_enabled" {
  type    = bool
  default = true
}

variable "patch_assessment_mode" {
  type    = string
  default = "AutomaticByPlatform"
}

variable "patch_mode" {
  type    = string
  default = "AutomaticByPlatform"
}

variable "tags" {
  type    = map(string)
  default = {}
}

resource "azurerm_windows_virtual_machine" "this" {
  name                  = var.name
  computer_name         = var.computer_name
  resource_group_name   = var.resource_group_name
  location              = var.location
  size                  = var.size
  admin_username        = var.admin_username
  admin_password        = var.admin_password
  network_interface_ids = var.network_interface_ids
  source_image_id       = var.source_image_id
  provision_vm_agent    = true
  patch_assessment_mode = var.patch_assessment_mode
  patch_mode            = var.patch_mode
  automatic_updates_enabled = false
  secure_boot_enabled   = var.secure_boot_enabled
  vtpm_enabled          = var.vtpm_enabled
  tags                  = var.tags
  /*
  source_image_reference {
    publisher = var.image_publisher
    offer     = var.image_offer
    sku       = var.image_sku
    version   = var.image_version
  }
*/
  os_disk {
    name                 = var.os_disk_name
    caching              = var.os_disk_caching
    storage_account_type = var.os_disk_storage_account_type
    disk_size_gb         = var.os_disk_size_gb
  }

lifecycle {
    ignore_changes = [
      patch_mode,
      patch_assessment_mode,
      bypass_platform_safety_checks_on_user_schedule_enabled
    ]
  }

  boot_diagnostics {}
}

output "id" {
  value = azurerm_windows_virtual_machine.this.id
}

output "name" {
  value = azurerm_windows_virtual_machine.this.name
}

output "os_disk_id" {
  value = azurerm_windows_virtual_machine.this.os_disk[0].id
}

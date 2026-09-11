variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "storage_account_type" {
  type = string
}

variable "disk_size_gb" {
  type = number
}

variable "tier" {
  type    = string
  default = null
}

variable "disk_iops_read_write" {
  type    = number
  default = null
}

variable "disk_mbps_read_write" {
  type    = number
  default = null
}

variable "tags" {
  type    = map(string)
  default = {}
}

resource "azurerm_managed_disk" "this" {
  name                 = var.name
  resource_group_name  = var.resource_group_name
  location             = var.location
  storage_account_type = var.storage_account_type
  create_option        = "Empty"
  disk_size_gb         = var.disk_size_gb
  tier                 = var.tier
  disk_iops_read_write = var.disk_iops_read_write
  disk_mbps_read_write = var.disk_mbps_read_write
  tags                 = var.tags
}

output "id" {
  value = azurerm_managed_disk.this.id
}

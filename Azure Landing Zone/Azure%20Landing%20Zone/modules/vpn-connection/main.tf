variable "name" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "virtual_network_gateway_id" {
  type = string
}
variable "local_network_gateway_id" {
  type = string
}
variable "shared_key" {
  type = string
  sensitive = true
}
variable "enable_bgp" {
  type = bool
  default = false
}
variable "routing_weight" {
  type = number
  default = 0
}
variable "dpd_timeout_seconds" {
  type = number
  default = 45
}
variable "connection_mode" {
  type = string
  default = "Default"
}
variable "ipsec_policy" {
  type = any
  default = null
}
variable "tags" {
  type = map(string)
  default = {}
}
resource "azurerm_virtual_network_gateway_connection" "this" {
  name                       = var.name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  type                       = "IPsec"
  virtual_network_gateway_id = var.virtual_network_gateway_id
  local_network_gateway_id   = var.local_network_gateway_id
  shared_key                 = var.shared_key
  enable_bgp                 = var.enable_bgp
  routing_weight             = var.routing_weight
  dpd_timeout_seconds        = var.dpd_timeout_seconds
  connection_mode            = var.connection_mode
  tags                       = var.tags

  dynamic "ipsec_policy" {
    for_each = var.ipsec_policy == null ? [] : [var.ipsec_policy]
    content {
      dh_group         = ipsec_policy.value.dh_group
      ike_encryption   = ipsec_policy.value.ike_encryption
      ike_integrity    = ipsec_policy.value.ike_integrity
      ipsec_encryption = ipsec_policy.value.ipsec_encryption
      ipsec_integrity  = ipsec_policy.value.ipsec_integrity
      pfs_group        = ipsec_policy.value.pfs_group
      sa_datasize      = try(ipsec_policy.value.sa_datasize, 102400000)
      sa_lifetime      = try(ipsec_policy.value.sa_lifetime, 27000)
    }
  }
}
output "id" {
  value = azurerm_virtual_network_gateway_connection.this.id
}

variable "name" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "account_tier" {
  type = string
  default = "Standard"
}
variable "account_replication_type" {
  type = string
  default = "LRS"
}
variable "account_kind" {
  type = string
  default = "StorageV2"
}
variable "access_tier" {
  type = string
  default = "Hot"
}
variable "public_network_access_enabled" {
  type = bool
  default = true
}
variable "shared_access_key_enabled" {
  type = bool
  default = true
}
variable "min_tls_version" {
  type = string
  default = "TLS1_2"
}
variable "allow_nested_items_to_be_public" {
  type = bool
  default = false
}
variable "network_default_action" {
  type = string
  default = "Allow"
}
variable "containers" {
  type = map(any)
  default = {}
}
variable "tags" {
  type = map(string)
  default = {}
}
resource "azurerm_storage_account" "this" {
  name                            = var.name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = var.account_tier
  account_replication_type        = var.account_replication_type
  account_kind                    = var.account_kind
  access_tier                     = var.access_tier
  https_traffic_only_enabled      = true
  min_tls_version                 = var.min_tls_version
  public_network_access_enabled   = var.public_network_access_enabled
  shared_access_key_enabled       = var.shared_access_key_enabled
  allow_nested_items_to_be_public = var.allow_nested_items_to_be_public
  tags                            = var.tags

  network_rules {
    default_action = var.network_default_action
    bypass         = ["AzureServices"]
  }
}
resource "azurerm_storage_container" "this" {
  for_each              = var.containers
  name                  = each.key
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = try(each.value.access_type, "private")
}
output "id" {
  value = azurerm_storage_account.this.id
}
output "name" {
  value = azurerm_storage_account.this.name
}
output "primary_blob_endpoint" {
  value = azurerm_storage_account.this.primary_blob_endpoint
}

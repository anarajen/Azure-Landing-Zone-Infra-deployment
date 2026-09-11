provider "azurerm" {
  features {}

  subscription_id = var.config.subscription_id
  tenant_id       = var.config.tenant_id

  storage_use_azuread = true
}
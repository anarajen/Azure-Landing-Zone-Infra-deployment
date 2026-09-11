module "logic" {
  source = "./modules/logic"

  providers = {
    azurerm = azurerm
    azapi   = azapi
  }

  config   = var.config
  secrets  = var.secrets
}
terraform {
  required_version = ">= 1.10.0, < 1.16.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "= 4.81.0"
    }
  }
}

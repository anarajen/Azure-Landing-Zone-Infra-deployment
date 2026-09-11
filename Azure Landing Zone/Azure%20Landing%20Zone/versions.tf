terraform {
  required_version = ">= 1.15.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.81.0"
    }

    azapi = {
      source  = "Azure/azapi"
      version = "2.10.0"
    }
  }
}
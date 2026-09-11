terraform {
  required_providers {
    azapi = {
      source = "Azure/azapi"
    }
  }
}

variable "managed_disk_id" {
  type = string
}

variable "tier" {
  type = string
}

resource "azapi_update_resource" "this" {
  type        = "Microsoft.Compute/disks@2025-01-02"
  resource_id = var.managed_disk_id

  body = {
    properties = {
      tier = var.tier
    }
  }
}

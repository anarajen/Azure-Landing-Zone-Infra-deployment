variable "name" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "virtual_network_name" {
  type = string
}
variable "address_prefixes" {
  type = list(string)
}
variable "private_endpoint_network_policies" {
  type = string
  default = null
}
variable "service_endpoints" {
  type = list(string)
  default = []
}

variable "delegation" {
  type = object({
    name                    = string
    service_delegation_name = string
    actions                 = list(string)
  })
  default = null
}

resource "azurerm_subnet" "this" {
  name                                      = var.name
  resource_group_name                       = var.resource_group_name
  virtual_network_name                      = var.virtual_network_name
  address_prefixes                          = var.address_prefixes
  private_endpoint_network_policies         = var.private_endpoint_network_policies
  service_endpoints                         = var.service_endpoints

    dynamic "delegation" {
    for_each = var.delegation == null ? [] : [var.delegation]

    content {
      name = delegation.value.name

      service_delegation {
        name    = delegation.value.service_delegation_name
        actions = delegation.value.actions
      }
    }
  }
}
output "id" {
  value = azurerm_subnet.this.id
}
output "name" {
  value = azurerm_subnet.this.name
}

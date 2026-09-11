variable "name" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "virtual_network_id" {
  type = string
}

variable "inbound_endpoint_name" {
  type = string
}

variable "inbound_subnet_id" {
  type = string
}

variable "inbound_private_ip_address" {
  type = string
}

variable "tags" {
  type    = map(string)
  default = {}
}


resource "azurerm_private_dns_resolver" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  virtual_network_id  = var.virtual_network_id
  tags                = var.tags
}


resource "azurerm_private_dns_resolver_inbound_endpoint" "this" {
  name                    = var.inbound_endpoint_name
  private_dns_resolver_id = azurerm_private_dns_resolver.this.id
  location                = var.location
  tags                    = var.tags

  ip_configurations {
    private_ip_allocation_method = "Static"
    private_ip_address           = var.inbound_private_ip_address
    subnet_id                    = var.inbound_subnet_id
  }
}


output "id" {
  value = azurerm_private_dns_resolver.this.id
}

output "name" {
  value = azurerm_private_dns_resolver.this.name
}

output "inbound_endpoint_id" {
  value = azurerm_private_dns_resolver_inbound_endpoint.this.id
}

output "inbound_private_ip_address" {
  value = var.inbound_private_ip_address
}
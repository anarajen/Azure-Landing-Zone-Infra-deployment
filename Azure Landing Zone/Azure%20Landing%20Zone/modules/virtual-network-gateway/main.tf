variable "name" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "sku" {
  type = string
}
variable "generation" {
  type = string
  default = "Generation1"
}
variable "active_active" {
  type = bool
  default = false
}
variable "enable_bgp" {
  type = bool
  default = false
}
variable "gateway_subnet_id" {
  type = string
}
variable "public_ip_address_id" {
  type = string
}
variable "second_public_ip_address_id" {
  type = string
  default = null
}
variable "bgp_asn" {
  type = number
  default = null
}
variable "p2s" {
  type = any
  default = null
}
variable "tags" {
  type = map(string)
  default = {}
}
resource "azurerm_virtual_network_gateway" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  type                = "Vpn"
  vpn_type            = "RouteBased"
  sku                 = var.sku
  generation          = var.generation
  active_active       = var.active_active
  enable_bgp          = var.enable_bgp
  tags                = var.tags

  ip_configuration {
    name                          = "vnetGatewayConfig1"
    public_ip_address_id          = var.public_ip_address_id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = var.gateway_subnet_id
  }

  dynamic "ip_configuration" {
    for_each = var.active_active && var.second_public_ip_address_id != null ? [1] : []
    content {
      name                          = "vnetGatewayConfig2"
      public_ip_address_id          = var.second_public_ip_address_id
      private_ip_address_allocation = "Dynamic"
      subnet_id                     = var.gateway_subnet_id
    }
  }

  dynamic "bgp_settings" {
    for_each = var.enable_bgp ? [1] : []
    content {
      asn = var.bgp_asn
    }
  }

  dynamic "vpn_client_configuration" {
    for_each = var.p2s == null ? [] : [var.p2s]
    content {
      address_space        = vpn_client_configuration.value.address_space
      vpn_client_protocols = vpn_client_configuration.value.vpn_client_protocols
      vpn_auth_types       = vpn_client_configuration.value.vpn_auth_types
      aad_tenant           = try(vpn_client_configuration.value.aad_tenant, null)
      aad_audience         = try(vpn_client_configuration.value.aad_audience, null)
      aad_issuer            = try(vpn_client_configuration.value.aad_issuer, null)
      radius_server_address = try(vpn_client_configuration.value.radius_server_address, null)
      radius_server_secret  = try(vpn_client_configuration.value.radius_server_secret, null)

      dynamic "root_certificate" {
        for_each = try(vpn_client_configuration.value.root_certificates, {})
        content {
          name             = root_certificate.key
          public_cert_data = root_certificate.value
        }
      }

      dynamic "revoked_certificate" {
        for_each = try(vpn_client_configuration.value.revoked_certificates, {})
        content {
          name       = revoked_certificate.key
          thumbprint = revoked_certificate.value
        }
      }
    }
  }
}
output "id" {
  value = azurerm_virtual_network_gateway.this.id
}
output "name" {
  value = azurerm_virtual_network_gateway.this.name
}

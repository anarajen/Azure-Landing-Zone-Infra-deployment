locals {
  p2s_auth = lower(try(var.config.p2s.authentication, ""))

  p2s_configuration = try(var.config.p2s.enabled, false) ? {
    address_space        = [local.p2s_cidr]
    vpn_client_protocols = local.p2s_auth == "entra" || local.p2s_auth == "aad" ? ["OpenVPN"] : try(var.config.p2s.protocols, ["OpenVPN"])
    vpn_auth_types       = local.p2s_auth == "entra" || local.p2s_auth == "aad" ? ["AAD"] : local.p2s_auth == "certificate" ? ["Certificate"] : local.p2s_auth == "radius" ? ["Radius"] : []
    aad_tenant           = local.p2s_auth == "entra" || local.p2s_auth == "aad" ? "https://login.microsoftonline.com/${local.tenant_id}/" : null
    aad_audience         = local.p2s_auth == "entra" || local.p2s_auth == "aad" ? try(var.config.p2s.aad_audience, null) : null
    aad_issuer           = local.p2s_auth == "entra" || local.p2s_auth == "aad" ? try(var.config.p2s.aad_issuer, null) : null
    root_certificates     = local.p2s_auth == "certificate" ? try(var.config.p2s.root_certificates, {}) : {}
    revoked_certificates  = local.p2s_auth == "certificate" ? try(var.config.p2s.revoked_certificates, {}) : {}
    radius_server_address = local.p2s_auth == "radius" ? try(var.config.p2s.radius_server_address, null) : null
    radius_server_secret  = local.p2s_auth == "radius" ? try(var.secrets.p2s_radius_secret, null) : null
  } : null
}

module "virtual_network_gateway" {
  source   = "../virtual-network-gateway"
  for_each = try(var.config.features.vpn_gateway, false) ? { main = true } : {}

  name                        = local.names.vng
  resource_group_name         = module.resource_groups["hub"].name
  location                    = local.region
  sku                         = try(var.config.vpn_gateway.sku, "VpnGw1AZ")
  generation                  = try(var.config.vpn_gateway.generation, "Generation1")
  active_active               = try(var.config.vpn_gateway.active_active, false)
  enable_bgp                  = try(var.config.vpn_gateway.enable_bgp, false)
  gateway_subnet_id           = module.subnets["gateway"].id
  public_ip_address_id        = module.public_ips["vng"].id
  second_public_ip_address_id = try(var.config.vpn_gateway.active_active, false) ? module.public_ips["vng2"].id : null
  bgp_asn                     = try(var.config.vpn_gateway.bgp_asn, null)
  p2s                         = local.p2s_configuration
  tags                        = local.common_tags
}

module "local_network_gateway" {
  source   = "../local-network-gateway"
  for_each = try(var.config.s2s.enabled, false) ? { office = true } : {}

  name                = local.names.lng
  resource_group_name = module.resource_groups["hub"].name
  location            = local.region
  gateway_address     = var.config.s2s.office_public_ip
  address_space       = var.config.s2s.office_prefixes
  bgp_settings = try(var.config.s2s.enable_bgp, false) ? {
    asn                 = var.config.s2s.bgp_asn
    bgp_peering_address = var.config.s2s.bgp_peer_ip
    peer_weight         = try(var.config.s2s.bgp_peer_weight, 0)
  } : null
  tags = local.common_tags
}

module "s2s_connection" {
  source   = "../vpn-connection"
  for_each = try(var.config.s2s.enabled, false) ? { office = true } : {}

  name                       = local.names.s2s
  resource_group_name        = module.resource_groups["hub"].name
  location                   = local.region
  virtual_network_gateway_id = module.virtual_network_gateway["main"].id
  local_network_gateway_id   = module.local_network_gateway["office"].id
  shared_key                 = var.secrets.s2s_shared_key
  enable_bgp                 = try(var.config.s2s.enable_bgp, false)
  routing_weight             = try(var.config.s2s.routing_weight, 0)
  dpd_timeout_seconds        = try(var.config.s2s.dpd_timeout_seconds, 45)
  connection_mode            = try(var.config.s2s.connection_mode, "Default")
  ipsec_policy               = try(var.config.s2s.ipsec_policy, null)
  tags                       = local.common_tags
}

module "resource_groups" {
  source   = "../resource-group"
  for_each = local.resource_groups
  name     = each.value.name
  location = local.region
  tags     = local.common_tags
}

module "vnets" {
  source   = "../virtual-network"
  for_each = local.vnets

  name                = each.value.name
  resource_group_name = module.resource_groups[each.value.rg_key].name
  location            = local.region
  address_space       = [each.value.cidr]
  dns_servers         = local.dns_servers
  tags                = local.common_tags
}

module "subnets" {
  source   = "../subnet"
  for_each = local.subnets

  name                              = each.value.name
  resource_group_name               = module.resource_groups[local.vnets[each.value.vnet_key].rg_key].name
  virtual_network_name              = module.vnets[each.value.vnet_key].name
  address_prefixes                  = [each.value.cidr]
  private_endpoint_network_policies = each.value.pe_policies
  delegation                        = try(each.value.delegation, null)
}

module "private_dns_resolver" {
  source = "../private-dns-resolver"

  name                = local.names.dns_resolver
  resource_group_name = module.resource_groups["hub"].name
  location            = local.region
  virtual_network_id  = module.vnets["hub"].id

  inbound_endpoint_name       = local.names.dns_inbound_endpoint
  inbound_subnet_id           = module.subnets["dns_inbound"].id
  inbound_private_ip_address  = local.dns_resolver_inbound_ip

  tags = local.common_tags
}

module "nsgs" {
  source   = "../network-security-group"
  for_each = local.nsg_names

  name                = each.value
  resource_group_name = each.key == "appgw" ? module.resource_groups["hub"].name : module.resource_groups["app"].name
  location            = local.region
  rules               = local.nsg_rules[each.key]
  tags                = local.common_tags
}

locals {
  nsg_subnet_map = {
    appgw = "appgw"
    web   = "web"
    app   = "app"
    pe    = "pe"
  }
}

module "nsg_subnet_associations" {
  source   = "../subnet-nsg-association"
  for_each = local.nsg_subnet_map

  subnet_id                 = module.subnets[each.value].id
  network_security_group_id = module.nsgs[each.key].id
}

module "peer_hub_to_app" {
  source = "../vnet-peering"

  name                         = local.names.peerings.hub_to_app
  resource_group_name          = module.resource_groups["hub"].name
  virtual_network_name         = module.vnets["hub"].name
  remote_virtual_network_id    = module.vnets["app"].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = try(var.config.network.allow_forwarded_traffic, false)
  allow_gateway_transit        = true
  use_remote_gateways          = false
}

module "peer_app_to_hub" {
  source = "../vnet-peering"

  name                         = local.names.peerings.app_to_hub
  resource_group_name          = module.resource_groups["app"].name
  virtual_network_name         = module.vnets["app"].name
  remote_virtual_network_id    = module.vnets["hub"].id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = try(var.config.network.allow_forwarded_traffic, false)
  allow_gateway_transit        = false
  use_remote_gateways          = try(var.config.features.vpn_gateway, false)

  depends_on = [module.virtual_network_gateway]
}

locals {
  public_ips = merge({
    nat = {
      name = local.names.pips.nat
      zones = try(var.config.network.nat_public_ip_zones, null)
    }
  }, try(var.config.features.vpn_gateway, false) ? {
    vng = {
      name = local.names.pips.vng
      zones = try(var.config.vpn_gateway.public_ip_zones, ["1", "2", "3"])
    }
  } : {}, try(var.config.features.application_gateway, false) ? {
    appgw = {
      name = local.names.pips.appgw
      zones = try(var.config.app_gateway.public_ip_zones, ["1", "2", "3"])
    }
  } : {}, try(var.config.vpn_gateway.active_active, false) ? {
    vng2 = {
      name = local.names.pips.vng2
      zones = try(var.config.vpn_gateway.public_ip_zones, ["1", "2", "3"])
    }
  } : {}, try(var.config.features.bastion, false) ? {
    bastion = {
      name = local.names.pips.bastion
      zones = try(var.config.bastion.public_ip_zones, null)
    }
  } : { }, try(var.config.features.smtp_lb, false) ? {
    smtp = {
      name  = local.names.pips.smtp
      zones = ["1", "2", "3"]        
    }
  } : {})
}

module "public_ips" {
  source   = "../public-ip"
  for_each = local.public_ips

  name                = each.value.name
  resource_group_name = module.resource_groups["hub"].name
  location            = local.region
  allocation_method   = "Static"
  sku                 = "Standard"
  ip_version          = "IPv4"
  zones                = each.value.zones
  ddos_protection_mode = contains(["appgw", "smtp"], each.key) && try(var.config.features.ddos_ip_protection, false) ? "Enabled" : null #each.key == "appgw" && try(var.config.features.ddos_ip_protection, false) ? "Enabled" : null
  tags                 = local.common_tags
}

module "nat_gateway" {
  source = "../nat-gateway"

  name                    = local.names.nat
  resource_group_name     = module.resource_groups["hub"].name
  location                = local.region
  public_ip_address_id    = module.public_ips["nat"].id
  idle_timeout_in_minutes = try(var.config.network.nat_idle_timeout_minutes, 4)
  zones                   = try(var.config.network.nat_zones, null)
  tags                    = local.common_tags
}

module "nat_subnet_associations" {
  source   = "../subnet-nat-association"
  #for_each = toset(["web", "app"])
  for_each = toset(["web", "app", "agent"])
  subnet_id      = module.subnets[each.key].id
  nat_gateway_id = module.nat_gateway.id
}

module "smtp_load_balancer" {
  source   = "../load-balancer"
  for_each = try(var.config.features.smtp_lb, false) ? { main = true } : {}

  name                           = local.names.smtp_lb
  resource_group_name            = module.resource_groups["hub"].name
  location                       = local.region
  sku                            = "Standard"
  sku_tier                       = "Regional"
  frontend_ip_configuration_name = "fip-${local.project}-smtp-01"
  public_ip_address_id           = module.public_ips["smtp"].id

  backend_pool_name = "bpool-smtp-01"

  probe = {
    name     = "hp-${local.project}-${local.region_code}-smtp-25"
    protocol = "Tcp"
    port     = 25
  }

  rule = {
    name                  = "lbr-${local.project}-${local.region_code}-smtp-25"
    protocol              = "Tcp"
    frontend_port         = 25
    backend_port          = 25
    disable_outbound_snat = true
  }

  tags = local.common_tags
}

resource "azurerm_network_interface_backend_address_pool_association" "nix_smtp" {
  for_each = try(var.config.features.smtp_lb, false) && local.compute_enabled ? { main = true } : {}

  network_interface_id    = module.nics["nix"].id
  ip_configuration_name   = "ipconfig1"
  backend_address_pool_id = module.smtp_load_balancer["main"].backend_pool_id
}
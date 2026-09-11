module "waf_policy" {
  source   = "../waf-policy"
  for_each = try(var.config.features.application_gateway, false) ? { main = true } : {}

  name                = local.names.waf
  resource_group_name = module.resource_groups["hub"].name
  location            = local.region
  mode                = try(var.config.app_gateway.waf_mode, "Detection")
  request_body_check          = try(var.config.app_gateway.request_body_check, true)
  max_request_body_size_in_kb = var.config.app_gateway.max_request_body_size_kb
  file_upload_limit_in_mb     = var.config.app_gateway.file_upload_limit_mb
  tags                        = local.common_tags
}

module "application_gateway" {
  source   = "../application-gateway"
  for_each = try(var.config.features.application_gateway, false) ? { main = true } : {}

  name                      = local.names.appgw
  resource_group_name       = module.resource_groups["hub"].name
  location                  = local.region
  zones                     = try(var.config.app_gateway.gateway_zones, ["1", "2", "3"])
  subnet_id                 = module.subnets["appgw"].id
  public_ip_address_id      = module.public_ips["appgw"].id
  waf_policy_id             = module.waf_policy["main"].id
  user_assigned_identity_id = module.appgw_uami["appgw"].id

  key_vault_secret_id = data.azurerm_key_vault_certificate.appgw.versionless_secret_id

  public_fqdns             = var.config.app_gateway.public_fqdns
  backend_fqdn             = var.config.app_gateway.private_fqdn
  backend_ip               = local.vm_private_ips.nix
  health_probe_path        = var.config.app_gateway.health_probe_path
  min_capacity             = 1
  max_capacity             = var.config.app_gateway.autoscale_max
  request_timeout          = var.config.app_gateway.request_timeout_seconds
  connection_drain_timeout = var.config.app_gateway.connection_drain_timeout_seconds
  enable_http_redirect     = try(var.config.app_gateway.enable_http_redirect, false)
  http2_enabled            = try(var.config.app_gateway.http2_enabled, false)
  ssl_policy_name          = try(var.config.app_gateway.ssl_policy_name, "AppGwSslPolicy20220101")

  component_names                = local.names.appgw_components
  trusted_root_certificate_name = try(var.config.app_gateway.trusted_root_certificate_name, null)
  trusted_root_certificate_data = try(var.secrets.trusted_root_certificate_data, null)

  tags = local.common_tags

  depends_on = [module.appgw_kv_role]
}

module "bastion" {
  source   = "../bastion"
  for_each = try(var.config.features.bastion, false) ? { main = true } : {}

  name                 = local.names.bastion
  resource_group_name  = module.resource_groups["hub"].name
  location             = local.region
  subnet_id            = module.subnets["bastion"].id
  public_ip_address_id = module.public_ips["bastion"].id
  sku                   = "Basic"
  tags                  = local.common_tags
}
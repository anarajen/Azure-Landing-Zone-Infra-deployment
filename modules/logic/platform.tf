data "azurerm_resource_group" "security" {
  name = local.names.resource_groups.sec
}

data "azurerm_key_vault" "main" {
  name                = local.names.key_vault
  resource_group_name = data.azurerm_resource_group.security.name
}

data "azurerm_key_vault_certificate" "appgw" {
  name         = "cert-iwmf2-nix-tls"
  key_vault_id = data.azurerm_key_vault.main.id
}

locals {
  platform_enabled   = try(var.config.features.platform_services, true)
  monitoring_enabled = try(var.config.features.monitoring, false)
  backup_enabled     = try(var.config.features.backup, false)
  private_only       = try(var.config.private_services.enforce_private_only, false)
}

module "appgw_uami" {
  source   = "../user-assigned-identity"
  for_each = try(var.config.features.application_gateway, false) ? { appgw = true } : {}

  name                = local.names.appgw_uami
  resource_group_name = data.azurerm_resource_group.security.name
  location            = local.region
  tags                = local.common_tags
}

module "appgw_kv_role" {
  source   = "../role-assignment"
  for_each = local.platform_enabled && try(var.config.features.application_gateway, false) ? { appgw = true } : {}

  scope                = data.azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.appgw_uami["appgw"].principal_id
  principal_type       = "ServicePrincipal"
}

module "operations_storage" {
  source   = "../storage-account"
  for_each = local.platform_enabled ? { main = true } : {}

  name                            = local.names.storage
  resource_group_name             = module.resource_groups["ops"].name
  location                        = local.region
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  account_kind                    = "StorageV2"
  access_tier                     = "Hot"
  public_network_access_enabled   = !local.private_only
  shared_access_key_enabled       = try(var.config.storage.shared_key_enabled, true)
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  network_default_action          = local.private_only ? "Deny" : "Allow"
  containers                      = try(var.config.storage.containers, {})
  tags                            = local.common_tags
}

module "recovery_services_vault" {
  source   = "../recovery-services-vault"
  for_each = local.backup_enabled ? { main = true } : {}

  name                          = local.names.rsv
  resource_group_name           = module.resource_groups["ops"].name
  location                      = local.region
  sku                           = "Standard"
  storage_mode_type             = "LocallyRedundant"
  public_network_access_enabled = !local.private_only
  tags                          = local.common_tags
}

module "log_analytics" {
  source   = "../log-analytics"
  for_each = local.monitoring_enabled ? { main = true } : {}

  name                       = local.names.law
  resource_group_name        = module.resource_groups["ops"].name
  location                   = local.region
  sku                        = try(var.config.monitoring.log_analytics_sku, "PerGB2018")
  retention_in_days          = try(var.config.monitoring.retention_in_days, 90)
  internet_ingestion_enabled = !local.private_only
  internet_query_enabled     = !local.private_only
  tags                       = local.common_tags
}

module "ampls" {
  source   = "../monitor-private-link-scope"
  for_each = local.monitoring_enabled ? { main = true } : {}

  name                  = local.names.ampls
  resource_group_name   = module.resource_groups["ops"].name
  ingestion_access_mode = local.private_only ? "PrivateOnly" : "Open"
  query_access_mode     = local.private_only ? "PrivateOnly" : "Open"

  scoped_services = {
    "scoped-law-${local.project}-${local.region_code}-01" = module.log_analytics["main"].id
  }

  tags = local.common_tags
}

module "private_dns_zones" {
  source   = "../private-dns-zone"
  for_each = try(var.config.features.private_endpoints, true) ? local.private_dns_zones : {}

  name                = each.value
  resource_group_name = data.azurerm_resource_group.security.name
  tags                = local.common_tags
}

locals {
  dns_links = try(var.config.features.private_endpoints, true) ? {
    for item in flatten([
      for zkey, zname in local.private_dns_zones : [
        {
          key      = "${zkey}-hub"
          zone_key = zkey
          vnet_key = "hub"
          name     = "link-${local.project}-${local.region_code}-${zkey}-hub-01"
        },
        {
          key      = "${zkey}-app"
          zone_key = zkey
          vnet_key = "app"
          name     = "link-${local.project}-${local.region_code}-${zkey}-app-01"
        }
      ]
    ]) : item.key => item
  } : {}
}

module "private_dns_links" {
  source   = "../private-dns-vnet-link"
  for_each = local.dns_links

  name                  = each.value.name
  resource_group_name   = data.azurerm_resource_group.security.name
  private_dns_zone_name = module.private_dns_zones[each.value.zone_key].name
  virtual_network_id    = module.vnets[each.value.vnet_key].id
  registration_enabled  = false
  tags                  = local.common_tags
}

resource "azurerm_private_dns_a_record" "nix_internal" {
  for_each = contains(keys(module.private_dns_zones), "internal") ? {
    nix = true
  } : {}

  name                = lower(local.vms.nix.computer_name)
  zone_name           = module.private_dns_zones["internal"].name
  resource_group_name = data.azurerm_resource_group.security.name
  ttl                 = 300

  records = [
    local.vm_private_ips.nix
  ]

  tags = local.common_tags

  depends_on = [
    module.private_dns_links
  ]
}

locals {
  private_endpoint_defs = merge(
    local.platform_enabled && try(var.config.features.private_endpoints, true) ? {
      kv = {
        name            = "pe-${local.project}-${local.region_code}-kv-01"
        nic_name        = "nic-pe-${local.project}-${local.region_code}-kv-01"
        connection_name = "plc-${local.project}-${local.region_code}-kv-01"

        target_id    = data.azurerm_key_vault.main.id
        subresources = ["vault"]
        zone_keys     = ["vault"]
        zone_group    = "dzg-${local.project}-${local.region_code}-kv-01"
      }

      st = {
        name            = "pe-${local.project}-${local.region_code}-st-01"
        nic_name        = "nic-pe-${local.project}-${local.region_code}-st-01"
        connection_name = "plc-${local.project}-${local.region_code}-st-01"

        target_id    = module.operations_storage["main"].id
        subresources = ["blob"]
        zone_keys     = ["blob"]
        zone_group    = "dzg-${local.project}-${local.region_code}-stblob-01"
      }
    } : {},

    local.backup_enabled && try(var.config.features.private_endpoints, true) ? {
      rsv = {
        name            = "pe-${local.project}-${local.region_code}-rsv-01"
        nic_name        = "nic-pe-${local.project}-${local.region_code}-rsv-01"
        connection_name = "plc-${local.project}-${local.region_code}-rsv-01"

        target_id    = module.recovery_services_vault["main"].id
        subresources = ["AzureBackup"]
        zone_keys     = concat(
          contains(keys(local.private_dns_zones), "backup") ? ["backup"] : [],
          ["blob", "queue"]
        )
        zone_group = "dzg-${local.project}-${local.region_code}-rsv-01"
      }
    } : {},

    local.monitoring_enabled && try(var.config.features.private_endpoints, true) ? {
      ampls = {
        name            = "pe-${local.project}-${local.region_code}-ampls-01"
        nic_name        = "nic-pe-${local.project}-${local.region_code}-ampls-01"
        connection_name = "plc-${local.project}-${local.region_code}-ampls-01"

        target_id    = module.ampls["main"].id
        subresources = ["azuremonitor"]
        zone_keys     = ["monitor", "oms", "ods", "agentsvc", "blob"]
        zone_group    = "dzg-${local.project}-${local.region_code}-ampls-01"
      }
    } : {}
  )
}

check "backup_private_dns" {
  assert {
    condition = (
      !local.backup_enabled ||
      !try(var.config.features.private_endpoints, true) ||
      contains(keys(local.private_dns_zones), "backup")
    )

    error_message = "Backup/private endpoint deployment is enabled but private_dns.backup_zone is empty. Provide the Azure Backup regional Private Link zone before enabling backup PE."
  }
}

module "private_endpoints" {
  source   = "../private-endpoint"
  for_each = local.private_endpoint_defs

  name = each.value.name

  resource_group_name = (
    each.key == "kv"
    ? data.azurerm_resource_group.security.name
    : module.resource_groups["ops"].name
  )

  location                       = local.region
  subnet_id                      = module.subnets["pe"].id
  custom_network_interface_name = each.value.nic_name

  connection_name                = each.value.connection_name
  private_connection_resource_id = each.value.target_id
  subresource_names              = each.value.subresources

  private_dns_zone_group_name = each.value.zone_group
  private_dns_zone_ids = [
    for key in each.value.zone_keys :
    module.private_dns_zones[key].id
  ]

  tags = local.common_tags

  depends_on = [
    module.private_dns_links
  ]
}

module "action_group" {
  source   = "../action-group"
  for_each = local.monitoring_enabled ? { main = true } : {}

  name                = local.names.action_group
  resource_group_name = module.resource_groups["ops"].name
  short_name          = "IWMF2OPS"
  email_receivers     = try(var.config.monitoring.email_receivers, {})
  tags                = local.common_tags
}
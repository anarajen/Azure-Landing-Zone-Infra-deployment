locals {
  diagnostic_targets = local.monitoring_enabled ? merge(
    {
      nat = module.nat_gateway.id
    },
    try(var.config.features.vpn_gateway, false) ? {
      vng = module.virtual_network_gateway["main"].id
    } : {},
    local.platform_enabled ? {
      kv = data.azurerm_key_vault.main.id
      st = module.operations_storage["main"].id
    } : {},
    local.backup_enabled ? {
      rsv = module.recovery_services_vault["main"].id
    } : {},
    try(var.config.features.application_gateway, false) ? {
      appgw = module.application_gateway["main"].id
    } : {}
  ) : {}
}

data "azurerm_monitor_diagnostic_categories" "targets" {
  for_each    = local.diagnostic_targets
  resource_id = each.value
}

module "diagnostic_settings" {
  source   = "../diagnostic-setting"
  for_each = local.diagnostic_targets

  name                       = "diag-${local.project}-${local.region_code}-${each.key}-01"
  target_resource_id         = each.value
  log_analytics_workspace_id = module.log_analytics["main"].id

  log_categories = data.azurerm_monitor_diagnostic_categories.targets[
    each.key
  ].log_category_types

  metric_categories = data.azurerm_monitor_diagnostic_categories.targets[
    each.key
  ].metrics
}

module "metric_alerts" {
  source   = "../metric-alert"
  for_each = local.monitoring_enabled ? try(var.config.monitoring.metric_alerts, {}) : {}

  name                     = each.key
  resource_group_name      = module.resource_groups["ops"].name
  scopes                   = each.value.scopes
  description              = try(each.value.description, null)
  severity                 = try(each.value.severity, 2)
  frequency                = try(each.value.frequency, "PT5M")
  window_size              = try(each.value.window_size, "PT15M")
  target_resource_type     = try(each.value.target_resource_type, null)
  target_resource_location = try(each.value.target_resource_location, null)
  criteria                 = each.value.criteria
  action_group_id          = module.action_group["main"].id
  tags                     = local.common_tags
}

module "defender_servers" {
  source   = "../defender"
  for_each = try(var.config.features.defender, false) ? { servers = true } : {}

  resource_type = "VirtualMachines"
  tier          = "Standard"
  subplan       = "P2"
}

module "defender_cspm" {
  source   = "../defender"
  for_each = try(var.config.features.defender, false) ? { cspm = true } : {}

  resource_type = "CloudPosture"
  tier          = "Standard"
}

module "defender_key_vault" {
  source   = "../defender"
  for_each = try(var.config.features.defender, false) ? { keyvault = true } : {}

  resource_type = "KeyVaults"
  tier          = "Standard"
}

module "defender_storage" {
  source   = "../defender"
  for_each = try(var.config.features.defender, false) ? { storage = true } : {}

  resource_type = "StorageAccounts"
  tier          = "Standard"
  subplan       = "DefenderForStorageV2"
}


check "budget_inputs" {
  assert {
    condition = !try(var.config.features.budget, false) || (
      try(var.config.budget.amount, 0) > 0 &&
      try(var.config.budget.start_date, "") != "" &&
      try(var.config.budget.end_date, "") != ""
    )

    error_message = "Budget deployment is enabled but amount/start_date/end_date are not approved/populated."
  }
}

module "budget" {
  source   = "../budget"
  for_each = try(var.config.features.budget, false) ? { main = true } : {}

  name            = local.names.budget
  subscription_id = "/subscriptions/${local.subscription_id}"
  amount          = var.config.budget.amount
  start_date      = var.config.budget.start_date
  end_date        = var.config.budget.end_date

  action_group_id = (
  local.monitoring_enabled
  ? module.action_group["main"].id
  : null
)

  contact_emails = try(var.config.budget.contact_emails, [])
}

module "policy_assignments" {
  source   = "../policy-assignment"
  for_each = try(var.config.security.policy_assignments, {})

  name                 = each.key
  display_name         = each.value.display_name
  policy_definition_id = each.value.policy_definition_id
  subscription_id      = "/subscriptions/${local.subscription_id}"
  parameters           = try(each.value.parameters, null)
  not_scopes           = try(each.value.not_scopes, [])
}

locals {
  lock_targets = try(var.config.features.locks, false) ? merge(
    {
      rg_hub = module.resource_groups["hub"].id
      rg_app = module.resource_groups["app"].id
      rg_ops = module.resource_groups["ops"].id
      rg_sec = data.azurerm_resource_group.security.id
    },
    local.platform_enabled ? {
      key_vault = data.azurerm_key_vault.main.id
    } : {},
    local.backup_enabled ? {
      rsv = module.recovery_services_vault["main"].id
    } : {}
  ) : {}
}

module "management_locks" {
  source   = "../management-lock"
  for_each = local.lock_targets

  name       = "lock-${each.key}-cannotdelete"
  scope      = each.value
  lock_level = "CanNotDelete"
  notes      = "Applied after IWMF2 validation/acceptance."
}
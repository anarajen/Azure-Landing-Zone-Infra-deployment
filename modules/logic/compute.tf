locals {
  compute_enabled = try(var.config.features.compute, false)
}

module "nics" {
  source   = "../network-interface"
  for_each = local.compute_enabled ? local.vms : {}

  name                           = local.nic_names[each.key]
  resource_group_name            = module.resource_groups["app"].name
  location                       = local.region
  subnet_id                      = module.subnets[each.value.subnet_key].id
  private_ip_address             = each.value.private_ip
  accelerated_networking_enabled = try(var.config.compute.accelerated_networking_enabled, false)
  ip_forwarding_enabled          = false
  dns_servers                    = []
  tags                           = local.common_tags
}

module "windows_vms" {
  source   = "../windows-vm"
  for_each = local.compute_enabled ? local.vms : {}

  name                         = each.value.name
  computer_name                = each.value.computer_name
  resource_group_name          = module.resource_groups["app"].name
  location                     = local.region
  size                         = each.value.size
  admin_username               = var.config.compute.admin_username
  admin_password               = var.secrets.vm_admin_password
  network_interface_ids        = [module.nics[each.key].id]
  source_image_id              = var.config.compute.source_image_id
  #image_sku                    = var.config.compute.image_sku
  os_disk_name                 = each.value.os_disk_name
  os_disk_storage_account_type = each.value.os_disk_type
  os_disk_size_gb              = each.value.os_disk_size_gb
  os_disk_caching              = each.value.os_disk_caching
  secure_boot_enabled          = try(var.config.compute.trusted_launch_enabled, false)
  vtpm_enabled                 = try(var.config.compute.trusted_launch_enabled, false)
  patch_assessment_mode        = "ImageDefault"
  patch_mode                   = "Manual"
  tags                         = local.common_tags
}


module "os_disk_performance_tier" {
  source = "../disk-performance-tier"

  providers = {
    azapi = azapi
  }
  for_each = local.compute_enabled ? {
    for key, vm in local.vms : key => vm if vm.os_performance_tier != null
  } : {}

  managed_disk_id = module.windows_vms[each.key].os_disk_id
  tier            = each.value.os_performance_tier
}

module "data_disks" {
  source   = "../managed-disk"
  for_each = local.compute_enabled ? local.data_disk_specs : {}

  name                 = each.value.name
  resource_group_name  = module.resource_groups["app"].name
  location             = local.region
  storage_account_type = each.value.storage_account_type
  disk_size_gb         = each.value.size_gb
  tier                 = each.value.tier
  disk_iops_read_write = each.value.iops
  disk_mbps_read_write = each.value.mbps
  tags                 = local.common_tags
}

module "data_disk_attachments" {
  source   = "../data-disk-attachment"
  for_each = local.compute_enabled ? local.data_disk_specs : {}

  managed_disk_id    = module.data_disks[each.key].id
  virtual_machine_id = module.windows_vms[each.value.vm_key].id
  lun                = each.value.lun
  caching            = each.value.caching
}

module "ama_extensions" {
  source   = "../vm-extension"
  for_each = local.compute_enabled && local.monitoring_enabled ? local.vms : {}

  name                      = "AzureMonitorWindowsAgent"
  virtual_machine_id        = module.windows_vms[each.key].id
  publisher                 = "Microsoft.Azure.Monitor"
  type                      = "AzureMonitorWindowsAgent"
  type_handler_version      = "1.0"
  automatic_upgrade_enabled = true
  tags                      = local.common_tags
}

module "dcr" {
  source   = "../data-collection-rule"
  for_each = local.monitoring_enabled ? { main = true } : {}

  name                  = local.names.dcr
  resource_group_name   = module.resource_groups["ops"].name
  location              = local.region
  workspace_resource_id = module.log_analytics["main"].id
  tags                  = local.common_tags
}

module "dcr_associations" {
  source   = "../dcr-association"
  for_each = local.compute_enabled && local.monitoring_enabled ? local.vms : {}

  name                    = "dcra-${local.project}-${local.region_code}-${each.key}-01"
  target_resource_id      = module.windows_vms[each.key].id
  data_collection_rule_id = module.dcr["main"].id

  depends_on = [module.ama_extensions]
}

check "backup_inputs" {
  assert {
    condition = !local.backup_enabled || (
      try(var.config.backup.time, "") != "" &&
      try(var.config.backup.retention_daily_count, 0) > 0
    )
    error_message = "Backup is enabled but backup.time or retention_daily_count is not approved/populated."
  }
}

module "backup_policy" {
  source   = "../backup-policy-vm"
  for_each = local.backup_enabled ? { main = true } : {}

  name                  = local.names.backup_policy
  resource_group_name   = module.resource_groups["ops"].name
  recovery_vault_name   = module.recovery_services_vault["main"].name
  timezone              = try(var.config.backup.timezone, "Singapore Standard Time")
  backup_time           = var.config.backup.time
  retention_daily_count = var.config.backup.retention_daily_count
}

module "backup_protected_vms" {
  source   = "../backup-protected-vm"
  for_each = local.compute_enabled && local.backup_enabled ? local.vms : {}

  resource_group_name = module.resource_groups["ops"].name
  recovery_vault_name = module.recovery_services_vault["main"].name
  source_vm_id         = module.windows_vms[each.key].id
  backup_policy_id     = module.backup_policy["main"].id

  depends_on = [module.private_endpoints]
}

locals {
  maintenance_enabled = try(var.config.features.maintenance, false)
}

check "maintenance_inputs" {
  assert {
    condition = !local.maintenance_enabled || (
      try(var.config.maintenance.start_date_time, "") != "" &&
      try(var.config.maintenance.duration, "") != "" &&
      try(var.config.maintenance.recur_every, "") != ""
    )
    error_message = "Maintenance is enabled but schedule values are incomplete."
  }
}

module "maintenance_configuration" {
  source   = "../maintenance-configuration"
  for_each = local.maintenance_enabled ? { main = true } : {}

  name                = local.names.maintenance
  resource_group_name = module.resource_groups["ops"].name
  location            = local.region
  start_date_time     = var.config.maintenance.start_date_time
  duration            = var.config.maintenance.duration
  time_zone           = try(var.config.maintenance.time_zone, "Singapore Standard Time")
  recur_every         = var.config.maintenance.recur_every
  reboot              = try(var.config.maintenance.reboot, "IfRequired")
  tags                = local.common_tags
}

module "maintenance_assignments" {
  source   = "../maintenance-assignment"
  for_each = local.compute_enabled && local.maintenance_enabled ? local.vms : {}

  location                     = local.region
  maintenance_configuration_id = module.maintenance_configuration["main"].id
  virtual_machine_id           = module.windows_vms[each.key].id
}

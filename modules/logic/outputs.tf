output "names" {
  value = local.names
}

output "subnet_cidrs" {
  value = local.subnet_cidrs
}

output "reserved_cidrs" {
  value = local.reserved_cidrs
}

output "vm_private_ips" {
  value = local.vm_private_ips
}

output "resource_group_ids" {
  value = { for k, v in module.resource_groups : k => v.id }
}

output "vnet_ids" {
  value = { for k, v in module.vnets : k => v.id }
}

output "subnet_ids" {
  value = { for k, v in module.subnets : k => v.id }
}

output "nsg_ids" {
  value = { for k, v in module.nsgs : k => v.id }
}

output "nat_gateway_id" {
  value = module.nat_gateway.id
}

output "vpn_gateway_id" {
  value = try(module.virtual_network_gateway["main"].id, null)
}

output "application_gateway_id" {
  value = try(module.application_gateway["main"].id, null)
}

output "vm_ids" {
  value = { for k, v in module.windows_vms : k => v.id }
}

output "public_ip_addresses" {
  value = { for k, v in module.public_ips : k => v.ip_address }
}

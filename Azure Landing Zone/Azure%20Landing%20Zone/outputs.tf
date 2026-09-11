output "calculated_names" {
  value = module.logic.names
}

output "calculated_subnet_cidrs" {
  value = module.logic.subnet_cidrs
}

output "reserved_cidrs" {
  value = module.logic.reserved_cidrs
}

output "vm_private_ips" {
  value = module.logic.vm_private_ips
}

output "resource_group_ids" {
  value = module.logic.resource_group_ids
}

output "vnet_ids" {
  value = module.logic.vnet_ids
}

output "subnet_ids" {
  value = module.logic.subnet_ids
}

output "nsg_ids" {
  value = module.logic.nsg_ids
}

output "nat_gateway_id" {
  value = module.logic.nat_gateway_id
}

output "vpn_gateway_id" {
  value = module.logic.vpn_gateway_id
}

output "application_gateway_id" {
  value = module.logic.application_gateway_id
}

output "vm_ids" {
  value = module.logic.vm_ids
}

output "public_ip_addresses" {
  value = module.logic.public_ip_addresses
}

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
  type    = string
  default = "Standard"
}
variable "sku_tier" {
  type    = string
  default = "Regional"
}
variable "frontend_ip_configuration_name" {
  type = string
}
variable "public_ip_address_id" {
  type    = string
  default = null
}
variable "backend_pool_name" {
  type = string
}
variable "probe" {
  type = object({
    name                = string
    protocol            = string
    port                = number
    interval_in_seconds = optional(number, 5)
    number_of_probes    = optional(number, 1)
    probe_threshold     = optional(number, 1)
    request_path        = optional(string, null)
  })
}
variable "rule" {
  type = object({
    name                    = string
    protocol                = string
    frontend_port           = number
    backend_port            = number
    idle_timeout_in_minutes = optional(number, 4)
    load_distribution       = optional(string, "Default")
    disable_outbound_snat   = optional(bool, false)
    enable_floating_ip      = optional(bool, false)
  })
}
variable "tags" {
  type    = map(string)
  default = {}
}

resource "azurerm_lb" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = var.sku
  sku_tier            = var.sku_tier
  tags                = var.tags

  frontend_ip_configuration {
    name                          = var.frontend_ip_configuration_name
    public_ip_address_id          = var.public_ip_address_id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_lb_backend_address_pool" "this" {
  name            = var.backend_pool_name
  loadbalancer_id = azurerm_lb.this.id
}

resource "azurerm_lb_probe" "this" {
  name                = var.probe.name
  loadbalancer_id     = azurerm_lb.this.id
  protocol            = var.probe.protocol
  port                = var.probe.port
  interval_in_seconds = var.probe.interval_in_seconds
  number_of_probes    = var.probe.number_of_probes
  probe_threshold     = var.probe.probe_threshold
  request_path        = var.probe.request_path
}

resource "azurerm_lb_rule" "this" {
  name                           = var.rule.name
  loadbalancer_id                = azurerm_lb.this.id
  frontend_ip_configuration_name = var.frontend_ip_configuration_name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.this.id]
  probe_id                       = azurerm_lb_probe.this.id
  protocol                       = var.rule.protocol
  frontend_port                  = var.rule.frontend_port
  backend_port                   = var.rule.backend_port
  idle_timeout_in_minutes        = var.rule.idle_timeout_in_minutes
  load_distribution              = var.rule.load_distribution
  disable_outbound_snat          = var.rule.disable_outbound_snat
  enable_floating_ip             = var.rule.enable_floating_ip
}

output "id" {
  value = azurerm_lb.this.id
}
output "backend_pool_id" {
  value = azurerm_lb_backend_address_pool.this.id
}
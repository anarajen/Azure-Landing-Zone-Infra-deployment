variable "name" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "zones" {
  type    = list(string)
  default = null
}
variable "subnet_id" {
  type = string
}
variable "public_ip_address_id" {
  type = string
}
variable "waf_policy_id" {
  type = string
}
variable "user_assigned_identity_id" {
  type = string
}
variable "key_vault_secret_id" {
  type = string
}
variable "public_fqdns" {
  type = list(string)
}
variable "backend_fqdn" {
  type = string
}
variable "backend_ip" {
  type    = string
  default = null
}
variable "health_probe_path" {
  type = string
}
variable "component_names" {
  type = object({
    gateway_ip_configuration  = string
    frontend_ip_configuration = string
    frontend_port_https       = string
    frontend_port_http        = string
    backend_pool              = string
    probe                     = string
    backend_setting           = string
    ssl_certificate           = string
    listener_https            = string
    listener_http             = string
    redirect_http_to_https    = string
    rule_https                = string
    rule_http_redirect        = string
  })
}
variable "min_capacity" {
  type    = number
  default = 2
}
variable "max_capacity" {
  type = number
}
variable "request_timeout" {
  type = number
}
variable "connection_drain_timeout" {
  type = number
}
variable "enable_http_redirect" {
  type    = bool
  default = false
}
variable "http2_enabled" {
  type    = bool
  default = false
}
variable "ssl_policy_name" {
  type    = string
  default = "AppGwSslPolicy20220101"
}
variable "trusted_root_certificate_name" {
  type    = string
  default = null
}
variable "trusted_root_certificate_data" {
  type      = string
  default   = null
  sensitive = true
}
variable "tags" {
  type    = map(string)
  default = {}
}

resource "azurerm_application_gateway" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  zones               = var.zones
  firewall_policy_id  = var.waf_policy_id
  http2_enabled       = var.http2_enabled
  tags                = var.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [var.user_assigned_identity_id]
  }

  sku {
    name = "WAF_v2"
    tier = "WAF_v2"
  }

  autoscale_configuration {
    min_capacity = var.min_capacity
    max_capacity = var.max_capacity
  }

  ssl_policy {
    policy_type = "Predefined"
    policy_name = var.ssl_policy_name
  }

  gateway_ip_configuration {
    name      = var.component_names.gateway_ip_configuration
    subnet_id = var.subnet_id
  }

  frontend_ip_configuration {
    name                 = var.component_names.frontend_ip_configuration
    public_ip_address_id = var.public_ip_address_id
  }

  frontend_port {
    name = var.component_names.frontend_port_https
    port = 443
  }

  dynamic "frontend_port" {
    for_each = var.enable_http_redirect ? [1] : []
    content {
      name = var.component_names.frontend_port_http
      port = 80
    }
  }

  backend_address_pool {
    name         = var.component_names.backend_pool
    #fqdns        = var.backend_fqdn != "" ? [var.backend_fqdn] : null
    #ip_addresses = var.backend_fqdn == "" && var.backend_ip != null ? [var.backend_ip] : null
    fqdns        = null
    ip_addresses = var.backend_ip != null ? [var.backend_ip] : null
  
  }

  probe {
    name                = var.component_names.probe
    protocol            = "Https"
    host                = var.backend_fqdn != "" ? var.backend_fqdn : var.backend_ip#var.backend_fqdn
    path                = var.health_probe_path
    interval            = 30
    timeout             = 30
    unhealthy_threshold = 3

    match {
      status_code = ["200-399"]
    }
  }

  backend_http_settings {
    name                           = var.component_names.backend_setting
    cookie_based_affinity          = "Disabled"
    port                           = 443
    protocol                       = "Https"
    request_timeout                = var.request_timeout
    host_name                      = var.backend_fqdn != "" ? var.backend_fqdn : null #var.backend_fqdn
    probe_name                     = var.component_names.probe
    trusted_root_certificate_names = var.trusted_root_certificate_name == null ? null : [var.trusted_root_certificate_name]

    connection_draining {
      enabled           = true
      drain_timeout_sec = var.connection_drain_timeout
    }
  }

  ssl_certificate {
    name                = var.component_names.ssl_certificate
    key_vault_secret_id = var.key_vault_secret_id
  }

  dynamic "trusted_root_certificate" {
    for_each = var.trusted_root_certificate_name != null && var.trusted_root_certificate_data != null ? [1] : []
    content {
      name = var.trusted_root_certificate_name
      data = var.trusted_root_certificate_data
    }
  }

  http_listener {
    name                           = var.component_names.listener_https
    frontend_ip_configuration_name = var.component_names.frontend_ip_configuration
    frontend_port_name             = var.component_names.frontend_port_https
    protocol                       = "Https"
    ssl_certificate_name           = var.component_names.ssl_certificate
    host_names                      = var.public_fqdns
    require_sni                    = true
  }

  request_routing_rule {
    name                       = var.component_names.rule_https
    priority                   = 100
    rule_type                  = "Basic"
    http_listener_name         = var.component_names.listener_https
    backend_address_pool_name  = var.component_names.backend_pool
    backend_http_settings_name = var.component_names.backend_setting
  }

  dynamic "http_listener" {
    for_each = var.enable_http_redirect ? [1] : []
    content {
      name                           = var.component_names.listener_http
      frontend_ip_configuration_name = var.component_names.frontend_ip_configuration
      frontend_port_name             = var.component_names.frontend_port_http
      protocol                       = "Http"
      host_names                     = var.public_fqdns
    }
  }

  dynamic "redirect_configuration" {
    for_each = var.enable_http_redirect ? [1] : []
    content {
      name                 = var.component_names.redirect_http_to_https
      redirect_type        = "Permanent"
      target_listener_name = var.component_names.listener_https
      include_path         = true
      include_query_string = true
    }
  }

  dynamic "request_routing_rule" {
    for_each = var.enable_http_redirect ? [1] : []
    content {
      name                        = var.component_names.rule_http_redirect
      priority                    = 110
      rule_type                   = "Basic"
      http_listener_name          = var.component_names.listener_http
      redirect_configuration_name = var.component_names.redirect_http_to_https
    }
  }
}

output "id" {
  value = azurerm_application_gateway.this.id
}
output "name" {
  value = azurerm_application_gateway.this.name
}

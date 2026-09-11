variable "name" {
  type = string
}
variable "resource_group_name" {
  type = string
}
variable "location" {
  type = string
}
variable "mode" {
  type    = string
  default = "Detection"
}
variable "request_body_check" {
  type    = bool
  default = true
}
variable "max_request_body_size_in_kb" {
  type = number
}
variable "file_upload_limit_in_mb" {
  type = number
}
variable "tags" {
  type    = map(string)
  default = {}
}

resource "azurerm_web_application_firewall_policy" "this" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  policy_settings {
    enabled                     = true
    mode                        = var.mode
    request_body_check          = var.request_body_check
    max_request_body_size_in_kb = var.max_request_body_size_in_kb
    file_upload_limit_in_mb     = var.file_upload_limit_in_mb
  }

  managed_rules {
    managed_rule_set {
      type    = "Microsoft_DefaultRuleSet"
      version = "2.2"
    }
  }
}

output "id" {
  value = azurerm_web_application_firewall_policy.this.id
}

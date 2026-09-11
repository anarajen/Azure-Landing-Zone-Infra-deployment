variable "name" {
  type = string
}
variable "subscription_id" {
  type = string
}
variable "amount" {
  type = number
}
variable "time_grain" {
  type = string
  default = "Monthly"
}
variable "start_date" {
  type = string
}
variable "end_date" {
  type = string
}
variable "action_group_id" {
  type = string
  default = null
}
variable "contact_emails" {
  type = list(string)
  default = []
}
resource "azurerm_consumption_budget_subscription" "this" {
  name            = var.name
  subscription_id = var.subscription_id
  amount          = var.amount
  time_grain      = var.time_grain
  time_period {
    start_date = var.start_date
    end_date   = var.end_date
  }
  notification {
    enabled        = true
    threshold      = 80
    operator       = "GreaterThan"
    threshold_type = "Actual"
    contact_emails = var.contact_emails
    contact_groups = var.action_group_id == null ? [] : [var.action_group_id]
  }
  notification {
    enabled        = true
    threshold      = 100
    operator       = "GreaterThan"
    threshold_type = "Forecasted"
    contact_emails = var.contact_emails
    contact_groups = var.action_group_id == null ? [] : [var.action_group_id]
  }
}

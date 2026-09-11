variable "config" {
  description = "Single data-driven configuration map from the root module."
  type        = any
}

variable "secrets" {
  description = "Sensitive runtime-only values supplied by Azure DevOps secret variables."
  type        = any
  sensitive   = true
  default     = {}
}

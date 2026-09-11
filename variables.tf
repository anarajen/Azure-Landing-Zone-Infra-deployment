variable "config" {
  description = "Single project configuration map. Root passes data only; naming, subnetting, resource maps and for_each logic live in modules/logic."
  type        = any
}

variable "secrets" {
  description = "Runtime secrets injected by Azure DevOps. Never commit these values to tfvars."
  type        = any
  sensitive   = true
  default     = {}
}

variable "config" {
  type = object({
    project         = string
    region          = string
    region_code     = string
    subscription_id = string
    tenant_id       = string
  })
}

variable "deployment_principal_id" {
  description = "Azure DevOps workload identity/service principal object ID used for Terraform state data-plane access."
  type        = string
  default     = ""
}

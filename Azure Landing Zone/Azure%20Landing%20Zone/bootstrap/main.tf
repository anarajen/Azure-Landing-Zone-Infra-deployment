locals {
  project     = lower(var.config.project)
  region_code = lower(var.config.region_code)

  # Terraform state resources
  resource_group_name  = "rg-${local.project}-${local.region_code}-tfstate-01"
  storage_account_name = "st${local.project}${local.region_code}tf01"

  # Bootstrap-owned Security RG + Key Vault
  security_rg_name = "rg-${local.project}-${local.region_code}-sec-01"
  key_vault_name   = "kv-${local.project}-${local.region_code}-sec-01"

  state_tags = {
    Application = upper(local.project)
    Environment = "Production"
    Region      = upper(local.region_code)
    ManagedBy   = "Terraform"
    Purpose     = "TerraformState"
  }

  security_tags = {
    Application = upper(local.project)
    Environment = "Production"
    Region      = upper(local.region_code)
    ManagedBy   = "Terraform"
    Owner       = "iwmf"
    Purpose     = "Security"
  }
}

# ============================================================
# Terraform State Resource Group
# ============================================================

module "state_rg" {
  source = "../modules/resource-group"

  name     = local.resource_group_name
  location = var.config.region
  tags     = local.state_tags
}

# ============================================================
# Terraform State Storage Account
# ============================================================

module "state_storage" {
  source = "../modules/storage-account"

  name                = local.storage_account_name
  resource_group_name = module.state_rg.name
  location            = var.config.region

  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  access_tier              = "Hot"

  public_network_access_enabled   = false
  shared_access_key_enabled       = false
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  network_default_action          = "Deny"

  containers = {
    tfstate = {
      access_type = "private"
    }
  }

  tags = local.state_tags
}

# ============================================================
# Terraform State RBAC
# ============================================================

module "state_blob_role" {
  source   = "../modules/role-assignment"
  for_each = var.deployment_principal_id != "" ? { pipeline = true } : {}

  scope                = module.state_storage.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = var.deployment_principal_id
  principal_type       = "ServicePrincipal"
}

# ============================================================
# Security Resource Group
# Bootstrap owns this RG.
# ============================================================

module "security_rg" {
  source = "../modules/resource-group"

  name     = local.security_rg_name
  location = var.config.region
  tags     = local.security_tags
}

# ============================================================
# Application Gateway prerequisite Key Vault
# Bootstrap owns this Key Vault.
# ============================================================

module "key_vault" {
  source = "../modules/key-vault"

  name                = local.key_vault_name
  resource_group_name = module.security_rg.name
  location            = var.config.region
  tenant_id           = var.config.tenant_id

  sku_name = "standard"

  public_network_access_enabled = false
  bypass                        = "AzureServices"
  network_default_action        = "Deny"

  tags = local.security_tags
}

module "deployment_kv_certificate_role" {
  source   = "../modules/role-assignment"
  for_each = var.deployment_principal_id != "" ? { pipeline = true } : {}

  scope                = module.key_vault.id
  role_definition_name = "Key Vault Certificate User"
  principal_id         = var.deployment_principal_id
  principal_type       = "ServicePrincipal"
}
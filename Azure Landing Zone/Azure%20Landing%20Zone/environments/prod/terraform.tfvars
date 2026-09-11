# IWMF2 Production - MINIMUM ROOT INPUT
# Root passes data only. The logic module calculates names, subnet CIDRs, VM IPs,
# known SKUs/settings, resource maps and all for_each child-module calls..

config = {
  project         = "iwmf"
  environment     = "prod"
  region          = "Southeast Asia"
  region_code     = "sea"

  subscription_id = "0bec3890-91f5-46f9-954a-434049775d9a"
  tenant_id       = "3931aa7a-2905-494d-81a2-a046c1c68db7"
  
  # Only parent networks are supplied. All Azure subnet CIDRs are derived in modules/logic.
  cidrs = {
    hub   = "172.16.0.0/20"
    spoke = "172.16.16.0/20"
    p2s   = "10.100.0.0/24"
  }

  owner       = "alvin.sim@vas-networks.com"
  extra_tags  = {}
  dns_servers = [] # TBC: existing customer AD/DNS server IPs.

  # Build gates. Baseline network/NSGs/NAT/VPN Gateway can deploy first.
  # Enable dependent services only after their input blocks below are complete.
  features = {
    vpn_gateway         = true
    application_gateway = true
    compute             = true
    platform_services   = true
    private_endpoints   = true
    monitoring          = true
    backup              = true
    maintenance         = true
    defender            = true
    budget              = true
    bastion             = false
    ddos_ip_protection  = true
    locks                = false
    smtp_lb              = true
  }

  network = {
    allow_forwarded_traffic = false
    pe_network_policies     = "Disabled"
    admin_source_cidrs      = [] # TBC: approved office/admin source CIDRs.

    nix_user_ports        = ["443"]
    app_user_ports        = []
    internet_egress_ports = ["443"]
    enable_nix_file_smb    = true
    enable_npcs_file_smb   = true
    enable_legacy_netbios  = false
    legacy_netbios_sources = []
    smtp_relay_cidrs       = []
    smtp_ports             = []
  }

  # Customer-side S2S values. PSK is supplied only through Azure DevOps secret S2S_SHARED_KEY.
  s2s = {
    enabled          = true
    office_public_ip = "66.96.196.178"
    office_prefixes  = ["172.16.37.0/24","172.16.77.0/24", "172.16.88.0/24", "192.168.133.0/24"]
    enable_bgp       = false
    bgp_asn          = null
    bgp_peer_ip      = ""
    ipsec_policy = {
      dh_group         = "DHGroup14"
      ike_encryption   = "AES256"
      ike_integrity    = "SHA256"
      ipsec_encryption = "AES256"
      ipsec_integrity  = "SHA256"
      pfs_group        = "PFS2048"
      sa_datasize      = 102400000
      sa_lifetime      = 28800
    }
  }

  # Final P2S authentication decision remains a build gate.
  # authentication: entra | certificate | radius
  p2s = {
    enabled               = true
    authentication        = "entra"
    aad_audience          = "c632b3df-fb67-4d84-bdcf-b95ad541b5c8"
    aad_issuer            = "https://sts.windows.net/156c941c-7388-4f00-bd7a-cf68a1fbf463/"
    root_certificates     = {}
    revoked_certificates  = {}
    radius_server_address = ""
  }

  # Only unresolved/approval-dependent Application Gateway values are root inputs.
  # Known values (WAF_v2, min=2, DRS 2.2, HTTPS/443, listener/rule/probe names, etc.) live in logic.
  app_gateway = {
    allowed_source_cidrs             = ["0.0.0.0/0"]
    public_fqdns                     = ["iwmfp2.sg"]
    private_fqdn                     = "iwmfp2.sg"
    health_probe_path                = "/"
    autoscale_max                    = 2
    request_timeout_seconds          = 30
    connection_drain_timeout_seconds = 30
    max_request_body_size_kb         = 128
    file_upload_limit_mb             = 100
    enable_http_redirect             = false
    trusted_root_certificate_name    = null
  }

  # Golden-image deployment inputs. Known VM names/SKUs/IPs/NIX+NPCS disk specs live in logic.
  compute = {
    source_image_id = "/subscriptions/0bec3890-91f5-46f9-954a-434049775d9a/resourceGroups/rg-acg-iwmf2-sea-01/providers/Microsoft.Compute/galleries/acgiwmf2sea01/images/win_2025_datacenter_gen_2_v1/versions/0.0.1"
    #image_sku                     = "2025-datacenter-azure-edition"
    admin_username                 = "adminuser"
    trusted_launch_enabled         = true
    accelerated_networking_enabled = false

    file_os_disk_size_gb   = 256
    file_os_disk_caching   = "ReadWrite"
    file_data_disk_size_gb = 1024
    file_data_disk_caching = "None"
  }

  private_dns = {
    backup_zone   = "privatelink.sea.backup.windowsazure.com"
    internal_zone = "iwmf2.internal"
  }

  private_services = {
    enforce_private_only = true # Set true only after PE/DNS/data-plane validation.
  }

  monitoring = {
    log_analytics_sku = "PerGB2018"
    email_receivers = {
  alvin = "alvin.sim@vas-networks.com"
    }
    metric_alerts     = {}
  }

  backup = {
    time                  = "22:00"
    retention_daily_count = 30
  }

  maintenance = {
    start_date_time = "2026-08-23 02:00"
    duration        = "03:00"
    recur_every     = "Week Sunday"
  }

  budget = {
    amount         = 3529.05
    start_date     = "2026-08-01T00:00:00Z"
    end_date       = "2027-08-01T00:00:00Z"
    contact_emails = []
  }

  security = {
    policy_assignments = {}
  }

  bastion = {
    subnet_cidr = "172.16.1.0/26"
  }
}
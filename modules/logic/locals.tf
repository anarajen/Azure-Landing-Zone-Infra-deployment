locals {
  project     = lower(var.config.project)
  region      = var.config.region
  region_code = lower(var.config.region_code)
  environment = lower(try(var.config.environment, "prod"))

  subscription_id = var.config.subscription_id
  tenant_id       = var.config.tenant_id

  hub_cidr   = var.config.cidrs.hub
  spoke_cidr = var.config.cidrs.spoke
  p2s_cidr   = try(var.config.cidrs.p2s, null)

  common_tags = merge({
    Application = upper(local.project) == "IWMF2" ? "IWMF2" : local.project
    Environment = "Production"
    Region      = upper(local.region_code)
    ManagedBy   = "Terraform"
    Owner       = try(var.config.owner, "TBC")
  }, try(var.config.extra_tags, {}))

  names = {
    resource_groups = {
      hub = "rg-${local.project}-${local.region_code}-hub-01"
      app = "rg-${local.project}-${local.region_code}-app-01"
      ops = "rg-${local.project}-${local.region_code}-ops-01"
      sec = "rg-${local.project}-${local.region_code}-sec-01"
    }

    vnets = {
      hub = "vnet-${local.project}-${local.region_code}-hub-01"
      app = "vnet-${local.project}-${local.region_code}-app-01"
    }

    subnets = {
      gateway     = "GatewaySubnet"
      appgw       = "snet-${local.project}-${local.region_code}-appgw-01"
      dns_inbound = "snet-${local.project}-${local.region_code}-dns-in-01"
      web         = "snet-${local.project}-${local.region_code}-web-01"
      pe          = "snet-${local.project}-${local.region_code}-pe-01"
      app         = "snet-${local.project}-${local.region_code}-app-01"
      agent      = "snet-${local.project}-${local.region_code}-agent-01"
    }

    nsgs = {
      appgw = "nsg-${local.project}-${local.region_code}-appgw-01"
      web   = "nsg-${local.project}-${local.region_code}-web-01"
      app   = "nsg-${local.project}-${local.region_code}-app-01"
      pe    = "nsg-${local.project}-${local.region_code}-pe-01"
    }

    peerings = {
      hub_to_app = "peer-${local.project}-${local.region_code}-hub-to-app-01"
      app_to_hub = "peer-${local.project}-${local.region_code}-app-to-hub-01"
    }

    pips = {
      appgw   = "pip-${local.project}-${local.region_code}-appgw-01"
      vng     = "pip-${local.project}-${local.region_code}-vng-01"
      vng2    = "pip-${local.project}-${local.region_code}-vng-02"
      nat     = "pip-${local.project}-${local.region_code}-nat-01"
      bastion = "pip-${local.project}-${local.region_code}-bastion-01"
      smtp    = "pip-${local.project}-${local.region_code}-smtp-01"
    }

    nat        = "nat-${local.project}-${local.region_code}-hub-01"
    vng        = "vng-${local.project}-${local.region_code}-hub-01"
    lng        = "lng-${local.project}-${local.region_code}-office-01"
    s2s        = "s2s-vpn-01"#"conn-${local.project}-${local.region_code}-office-01"
    appgw      = "agw-${local.project}-${local.region_code}-hub-01"
    waf        = "waf-${local.project}-${local.region_code}-nix-01"
    appgw_uami = "id-${local.project}-${local.region_code}-appgw-01"
    #smtp        = "pip-${local.project}-${local.region_code}-smtp-01"   # ADD
    smtp_lb     = "elb-${local.project}-${local.region_code}-smpt-01"

    appgw_components = {
      gateway_ip_configuration = "gip-${local.project}-${local.region_code}-appgw-01"
      frontend_ip_configuration = "fipcfg-${local.project}-${local.region_code}-appgw-01"
      frontend_port_https       = "fp-${local.project}-${local.region_code}-https-443"
      frontend_port_http        = "fp-${local.project}-${local.region_code}-http-80"
      backend_pool              = "be-${local.project}-${local.region_code}-nix-01"
      probe                     = "hp-${local.project}-${local.region_code}-nix-01"
      backend_setting           = "bhs-${local.project}-${local.region_code}-nix-https-01"
      ssl_certificate           = "cert-${local.project}-nix-tls"
      listener_https            = "lst-${local.project}-${local.region_code}-nix-https-01"
      listener_http             = "lst-${local.project}-${local.region_code}-nix-http-01"
      redirect_http_to_https    = "redir-${local.project}-${local.region_code}-http-to-https-01"
      rule_https                = "rr-https-nix"
      rule_http_redirect        = "rr-http-redirect"
    }

    key_vault    = "kv-${local.project}-${local.region_code}-sec-01"
    storage      = "st${local.project}${local.region_code}ops01"
    rsv          = "rsv-${local.project}-${local.region_code}-ops-01"
    law          = "law-${local.project}-${local.region_code}-ops-01"
    ampls        = "ampls-${local.project}-${local.region_code}-ops-01"
    dcr          = "dcr-${local.project}-${local.region_code}-win-01"
    action_group = "ag-${local.project}-${local.region_code}-ops-01"
    backup_policy = "bp-${local.project}-${local.region_code}-daily-01"
    maintenance   = "mc-${local.project}-${local.region_code}-win-01"
    budget               = "bud-${local.project}-${local.region_code}-prod-01"
    bastion              = "bas-${local.project}-${local.region_code}-hub-01"
    dns_resolver         = "dnspr-${local.project}-${local.region_code}-hub-01"
    dns_inbound_endpoint = "dnsin-${local.project}-${local.region_code}-hub-01"
  }

  subnet_cidrs = {
    gateway     = cidrsubnet(local.hub_cidr, 7, 0)
    appgw       = cidrsubnet(local.hub_cidr, 4, 8)
    dns_inbound = cidrsubnet(local.hub_cidr, 8, 2)
    agent       =  "172.16.16.128/26"
    web         = cidrsubnet(local.spoke_cidr, 7, 0)
    pe          = cidrsubnet(local.spoke_cidr, 7, 1)
    app         = cidrsubnet(local.spoke_cidr, 7, 2)
  }

  dns_resolver_inbound_ip = cidrhost(local.subnet_cidrs.dns_inbound, 4)

  reserved_cidrs = {
    azure_firewall_reserved = cidrsubnet(local.hub_cidr, 6, 1)
    management_reserved     = cidrsubnet(local.hub_cidr, 4, 1)
    hub_growth_1            = cidrsubnet(local.hub_cidr, 3, 1)
    hub_growth_2            = cidrsubnet(local.hub_cidr, 2, 1)
    spoke_app_growth        = cidrsubnet(local.spoke_cidr, 4, 1)
    spoke_growth            = cidrsubnet(local.spoke_cidr, 3, 1)
  }

  vm_private_ips = {
    nix  = cidrhost(local.subnet_cidrs.web, 10)
    npcs = cidrhost(local.subnet_cidrs.app, 6)
    file = cidrhost(local.subnet_cidrs.app, 7)
  }

  resource_groups = {
    for key, name in local.names.resource_groups : key => {
      name = name
    } if key != "sec"
  }

  vnets = {
    hub = {
      name   = local.names.vnets.hub
      rg_key = "hub"
      cidr   = local.hub_cidr
    }

    app = {
      name   = local.names.vnets.app
      rg_key = "app"
      cidr   = local.spoke_cidr
    }
  }

  subnets = merge(
    {
      gateway = {
        name        = local.names.subnets.gateway
        vnet_key    = "hub"
        cidr        = local.subnet_cidrs.gateway
        pe_policies = null
      }

      appgw = {
        name        = local.names.subnets.appgw
        vnet_key    = "hub"
        cidr        = local.subnet_cidrs.appgw
        pe_policies = null
      }

      agent = {
        name        = local.names.subnets.agent
        vnet_key    = "app"
        cidr        = local.subnet_cidrs.agent
        pe_policies = null
      }

      dns_inbound = {
        name        = local.names.subnets.dns_inbound
        vnet_key    = "hub"
        cidr        = local.subnet_cidrs.dns_inbound
        pe_policies = null

        delegation = {
          name                    = "Microsoft.Network.dnsResolvers"
          service_delegation_name = "Microsoft.Network/dnsResolvers"
          actions = [
            "Microsoft.Network/virtualNetworks/subnets/join/action"
          ]
        }
      }

      web = {
        name        = local.names.subnets.web
        vnet_key    = "app"
        cidr        = local.subnet_cidrs.web
        pe_policies = null
      }

      pe = {
        name        = local.names.subnets.pe
        vnet_key    = "app"
        cidr        = local.subnet_cidrs.pe
        pe_policies = try(var.config.features.private_endpoints, false) ? var.config.network.pe_network_policies : null
      }

      app = {
        name        = local.names.subnets.app
        vnet_key    = "app"
        cidr        = local.subnet_cidrs.app
        pe_policies = null
      }
    },

    {
      for key, subnet in {
        bastion = {
          name        = "AzureBastionSubnet"
          vnet_key    = "hub"
          cidr        = try(var.config.bastion.subnet_cidr, "")
          pe_policies = null
        }
      } : key => subnet

      if try(var.config.features.bastion, false) &&
      try(var.config.bastion.subnet_cidr, "") != ""
    }
  )

  nsg_names = local.names.nsgs

  office_prefixes = try(var.config.s2s.office_prefixes, [])

  admin_source_prefixes = distinct(compact(concat(
    try(var.config.network.admin_source_cidrs, []),
    local.office_prefixes,
    local.p2s_cidr == null ? [] : [local.p2s_cidr]
  )))

  dns_servers = try(var.config.dns_servers, [])

  appgw_sources = try(var.config.app_gateway.allowed_source_cidrs, [])

  nsg_rules = {
    appgw = merge(
      {
        gateway_manager = {
          name                       = "Allow-GatewayManager"
          priority                   = 120
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "65200-65535"
          source_address_prefix      = "GatewayManager"
          destination_address_prefix = "*"
          description                = "Azure Application Gateway v2 platform management."
        }

        azure_lb = {
          name                       = "Allow-AzureLoadBalancer"
          priority                   = 130
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "AzureLoadBalancer"
          destination_address_prefix = "*"
          description                = "Azure platform load balancer health traffic."
        }

        deny_in = {
          name                       = "Deny-All-Inbound"
          priority                   = 4096
          direction                  = "Inbound"
          access                     = "Deny"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
          description                = "Explicit deny after approved Application Gateway inbound rules."
        }
      },

      {
        for key, rule in {
          client_https = {
            name                       = "Allow-Client-HTTPS"
            priority                   = 100
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_port_range          = "*"
            destination_port_range     = "443"
            source_address_prefixes    = local.appgw_sources
            destination_address_prefix = "*"
            description                = "Approved public HTTPS sources to Application Gateway."
          }
        } : key => rule

        if length(local.appgw_sources) > 0
      },

      {
        for key, rule in {
          client_http = {
            name                       = "Allow-Client-HTTP-Redirect"
            priority                   = 110
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_port_range          = "*"
            destination_port_range     = "80"
            source_address_prefixes    = local.appgw_sources
            destination_address_prefix = "*"
            description                = "Optional HTTP to HTTPS redirect only."
          }
        } : key => rule

        if try(var.config.app_gateway.enable_http_redirect, false) &&
        length(local.appgw_sources) > 0
      }
    )

    web = merge(
      {
        appgw_nix = {
          name                       = "Allow-AppGW-NIX-HTTPS"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = local.subnet_cidrs.appgw
          destination_address_prefix = local.vm_private_ips.nix
          description                = "Application Gateway backend and health probe to NIX HTTPS/443."
        }

        npcs_nix = {
          name                       = "Allow-NPCS-NIX-HTTPS"
          priority                   = 110
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = local.vm_private_ips.npcs
          destination_address_prefix = local.vm_private_ips.nix
          description                = "NPCS to NIX HTTPS communication."
        }

        pe_https = {
          name                       = "Allow-PrivateEndpoints"
          priority                   = 210
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = local.subnet_cidrs.web
          destination_address_prefix = local.subnet_cidrs.pe
          description                = "Web tier to project private endpoints."
        }

        internet_https = {
          name                       = "Allow-Internet-via-NAT"
          priority                   = 220
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_ranges    = try(var.config.network.internet_egress_ports, ["443"])
          source_address_prefix      = local.subnet_cidrs.web
          destination_address_prefix = "Internet"
          description                = "HTTPS Internet egress; source NAT is performed by NAT Gateway. NSG does not provide FQDN filtering."
        }
        
        Outbound_smtp = {
          name                       = "Allow-Secure-SMTP-via-NAT"
          priority                   = 201
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "587"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
          description                = "Outbound Secure SMTP on Port 587"
        }
        deny_in = {
          name                       = "Deny-All-Inbound"
          priority                   = 4096
          direction                  = "Inbound"
          access                     = "Deny"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
          description                = "Explicit Web Tier inbound deny."
        }
      },

      {
        for key, rule in {
          dns = {
            name                         = "Allow-DNS"
            priority                     = 200
            direction                    = "Outbound"
            access                       = "Allow"
            protocol                     = "*"
            source_port_range            = "*"
            destination_port_range       = "53"
            source_address_prefix        = local.subnet_cidrs.web
            destination_address_prefixes = local.dns_servers
            description                  = "Web Tier DNS to customer-approved AD/DNS resolvers."
          }
        } : key => rule

        if length(local.dns_servers) > 0
      },

      {
        for key, rule in {
          office_p2s = {
            name                       = "Allow-Office-P2S-Newforma"
            priority                   = 120
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_port_range          = "*"
            destination_port_ranges    = try(var.config.network.nix_user_ports, [])
            source_address_prefixes    = local.admin_source_prefixes
            destination_address_prefix = local.vm_private_ips.nix
            description                = "Office/P2S access using only the approved Newforma port matrix."
          }
        } : key => rule

        if length(local.admin_source_prefixes) > 0 &&
        length(try(var.config.network.nix_user_ports, [])) > 0
      },
      {
        for key, rule in {
          p2s_rdp = {
            name                       = "Allow-P2S-RDP-NIX"
            priority                   = 125
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_port_range          = "*"
            destination_port_range     = "3389"
            source_address_prefix      = local.p2s_cidr
            destination_address_prefix = local.vm_private_ips.nix
            description                = "Allow RDP to NIX Web Server from Azure P2S VPN clients."
          }
        } : key => rule

        if try(var.config.p2s.enabled, false) &&
        local.p2s_cidr != null
      },

      {
        for key, rule in {
          bastion_rdp = {
            name                       = "Allow-Bastion-RDP"
            priority                   = 130
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_port_range          = "*"
            destination_port_range     = "3389"
            source_address_prefix      = try(local.subnets.bastion.cidr, "")
            destination_address_prefix = local.vm_private_ips.nix
            description                = "Administrative RDP from Azure Bastion only when Bastion is approved."
          }
        } : key => rule

        if try(var.config.features.bastion, false) &&
        contains(keys(local.subnets), "bastion")
      }
    )

    app = merge(
      {
        npcs_nix = {
          name                       = "Allow-NPCS-NIX-HTTPS"
          priority                   = 200
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = local.vm_private_ips.npcs
          destination_address_prefix = local.vm_private_ips.nix
          description                = "NPCS outbound HTTPS/443 to NIX."
        }

        pe_https = {
          name                       = "Allow-PrivateEndpoints"
          priority                   = 230
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefix      = local.subnet_cidrs.app
          destination_address_prefix = local.subnet_cidrs.pe
          description                = "App Tier to project private endpoints."
        }

        internet_https = {
          name                       = "Allow-Internet-via-NAT"
          priority                   = 240
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_ranges    = try(var.config.network.internet_egress_ports, ["443"])
          source_address_prefix      = local.subnet_cidrs.app
          destination_address_prefix = "Internet"
          description                = "HTTPS Internet egress through NAT Gateway."
        }

        Outbound_smtp = {
          name                       = "Allow-Secure-SMTP-via-NAT"
          priority                   = 201
          direction                  = "Outbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "587"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
          description                = "Outbound Secure SMTP on Port 587"
        }

        deny_in = {
          name                       = "Deny-All-Inbound"
          priority                   = 4096
          direction                  = "Inbound"
          access                     = "Deny"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
          description                = "Explicit App Tier inbound deny."
        }
      },

      {
        for key, rule in {
          dns = {
            name                         = "Allow-DNS"
            priority                     = 210
            direction                    = "Outbound"
            access                       = "Allow"
            protocol                     = "*"
            source_port_range            = "*"
            destination_port_range       = "53"
            source_address_prefix        = local.subnet_cidrs.app
            destination_address_prefixes = local.dns_servers
            description                  = "App Tier DNS to customer-approved AD/DNS resolvers."
          }
        } : key => rule

        if length(local.dns_servers) > 0
      },
            {
        for key, rule in {
          nix_file_smb = {
            name                       = "Allow-NIX-File-SMB"
            priority                   = 135
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_port_range          = "*"
            destination_port_range     = "445"
            source_address_prefix      = local.vm_private_ips.nix
            destination_address_prefix = local.vm_private_ips.file
            description                = "Allow SMB/445 from NIX Web Server to File Server."
          }
        } : key => rule

        if try(var.config.network.enable_nix_file_smb, false)
      },
      {
        for key, rule in {
          office_p2s = {
            name                         = "Allow-Office-P2S-App"
            priority                     = 100
            direction                    = "Inbound"
            access                       = "Allow"
            protocol                     = "Tcp"
            source_port_range            = "*"
            destination_port_ranges      = try(var.config.network.app_user_ports, [])
            source_address_prefixes      = local.admin_source_prefixes
            destination_address_prefixes = [
              local.vm_private_ips.npcs,
              local.vm_private_ips.file
            ]
            description = "Office/P2S access using approved application/admin ports."
          }
        } : key => rule

        if length(local.admin_source_prefixes) > 0 &&
        length(try(var.config.network.app_user_ports, [])) > 0
      },

      {
        for key, rule in {
          bastion_rdp = {
            name                         = "Allow-Bastion-RDP"
            priority                     = 110
            direction                    = "Inbound"
            access                       = "Allow"
            protocol                     = "Tcp"
            source_port_range            = "*"
            destination_port_range       = "3389"
            source_address_prefix        = try(local.subnets.bastion.cidr, "")
            destination_address_prefixes = [
              local.vm_private_ips.npcs,
              local.vm_private_ips.file
            ]
            description = "Administrative RDP from Azure Bastion only when approved."
          }
        } : key => rule

        if try(var.config.features.bastion, false) &&
        contains(keys(local.subnets), "bastion")
      },
      {
        for key, rule in {
          p2s_rdp = {
            name                       = "Allow-P2S-RDP-App"
            priority                   = 105
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_port_range          = "*"
            destination_port_range     = "3389"
            source_address_prefix      = local.p2s_cidr
            destination_address_prefixes = [
              local.vm_private_ips.npcs,
              local.vm_private_ips.file
            ]
            description = "Allow RDP to NPCS/File servers from Azure P2S VPN clients."
          }
        } : key => rule

        if try(var.config.p2s.enabled, false) &&
        local.p2s_cidr != null
      },
            {
        smtp_inbound_nix = {
          name                       = "Allow-SMTP-NIX-Inbound-25"
          priority                   = 104
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "25"
          source_address_prefix      = "*"
          destination_address_prefix = local.vm_private_ips.nix
          description                = "SMTP/25 inbound to NIX."
        }
        
      },
      {
        for key, rule in {
          npcs_file_smb = {
            name                       = "Allow-NPCS-File-SMB"
            priority                   = 120
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_port_range          = "*"
            destination_port_range     = "445"
            source_address_prefix      = local.vm_private_ips.npcs
            destination_address_prefix = local.vm_private_ips.file
            description                = "NPCS to File Server SMB/445 after signed Newforma/vendor approval."
          }
        } : key => rule

        if try(var.config.network.enable_npcs_file_smb, false)
      },
             {
        for key, rule in {
          p2s_file_smb = {
            name                       = "Allow-P2S-SMB-File"
            priority                   = 115
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_port_range          = "*"
            destination_port_range     = "445"
            source_address_prefix      = local.p2s_cidr
            destination_address_prefix = local.vm_private_ips.file
            description                = "Allow SMB/445 to File Server from Azure P2S VPN clients."
          }
        } : key => rule

        if try(var.config.p2s.enabled, false) &&
        local.p2s_cidr != null
      },
      {
        for key, rule in {
          legacy_netbios_udp = {
            name                       = "Allow-Legacy-NetBIOS-UDP"
            priority                   = 130
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Udp"
            source_port_range          = "*"
            destination_port_ranges    = ["137", "138"]
            source_address_prefixes    = try(var.config.network.legacy_netbios_sources, [])
            destination_address_prefix = local.vm_private_ips.file
            description                = "Legacy NetBIOS UDP only after signed Newforma approval."
          }

          legacy_netbios_tcp = {
            name                       = "Allow-Legacy-NetBIOS-TCP"
            priority                   = 140
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_port_range          = "*"
            destination_port_range     = "139"
            source_address_prefixes    = try(var.config.network.legacy_netbios_sources, [])
            destination_address_prefix = local.vm_private_ips.file
            description                = "Legacy NetBIOS TCP only after signed Newforma approval."
          }
        } : key => rule

        if try(var.config.network.enable_legacy_netbios, false) &&
        length(try(var.config.network.legacy_netbios_sources, [])) > 0
      },

      {
        for key, rule in {
          smtp = {
            name                         = "Allow-SMTP"
            priority                     = 220
            direction                    = "Outbound"
            access                       = "Allow"
            protocol                     = "Tcp"
            source_port_range            = "*"
            destination_port_ranges      = try(var.config.network.smtp_ports, [])
            source_address_prefix        = local.vm_private_ips.npcs
            destination_address_prefixes = try(var.config.network.smtp_relay_cidrs, [])
            description                  = "NPCS to approved SMTP relay only after customer approval."
          }
        } : key => rule

        if length(try(var.config.network.smtp_relay_cidrs, [])) > 0 &&
        length(try(var.config.network.smtp_ports, [])) > 0
      }
    )

    pe = merge(
      {
        hub_spoke_https = {
          name                       = "Allow-Hub-Spoke-PE-HTTPS"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "443"
          source_address_prefixes    = [local.hub_cidr, local.spoke_cidr]
          destination_address_prefix = local.subnet_cidrs.pe
          description                = "Hub/Spoke access to project private endpoints over HTTPS."
        }

        deny_in = {
          name                       = "Deny-All-Inbound"
          priority                   = 4096
          direction                  = "Inbound"
          access                     = "Deny"
          protocol                   = "*"
          source_port_range          = "*"
          destination_port_range     = "*"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
          description                = "Explicit private-endpoint subnet inbound deny."
        }
      },

      {
        for key, rule in {
          office_p2s = {
            name                       = "Allow-Office-P2S-PE-HTTPS"
            priority                   = 110
            direction                  = "Inbound"
            access                     = "Allow"
            protocol                   = "Tcp"
            source_port_range          = "*"
            destination_port_range     = "443"
            source_address_prefixes    = local.admin_source_prefixes
            destination_address_prefix = local.subnet_cidrs.pe
            description                = "Approved office/P2S access to project private endpoints."
          }
        } : key => rule

        if length(local.admin_source_prefixes) > 0
      }
    )
  }

  vms = {
    nix = {
      name                = "vm-${local.project}-${local.region_code}-nix-01"
      computer_name       = "${upper(local.project)}NIX01"
      subnet_key          = "web"
      private_ip          = local.vm_private_ips.nix
      size                = "Standard_DC4ds_v3"
      os_disk_name        = "disk-${local.project}-${local.region_code}-nix-os-01"
      os_disk_type        = "Premium_LRS"
      os_disk_size_gb     = 128
      os_disk_caching     = "ReadWrite"
      os_performance_tier = "P30"
    }

    npcs = {
      name                = "vm-${local.project}-${local.region_code}-npcs-01"
      computer_name       = "${upper(local.project)}NPCS01"
      subnet_key          = "app"
      private_ip          = local.vm_private_ips.npcs
      size                = "Standard_DC4ds_v3"
      os_disk_name        = "disk-${local.project}-${local.region_code}-npcs-os-01"
      os_disk_type        = "Premium_LRS"
      os_disk_size_gb     = 128
      os_disk_caching     = "ReadWrite"
      os_performance_tier = "P30"
    }

    file = {
      name                = "vm-${local.project}-${local.region_code}-file-01"
      computer_name       = "${upper(local.project)}FILE01"
      subnet_key          = "app"
      private_ip          = local.vm_private_ips.file
      size                = "Standard_DC4ds_v3"
      os_disk_name        = "disk-${local.project}-${local.region_code}-file-os-01"
      os_disk_type        = "StandardSSD_LRS"
      os_disk_size_gb     = try(var.config.compute.file_os_disk_size_gb, 0)
      os_disk_caching     = try(var.config.compute.file_os_disk_caching, "")
      os_performance_tier = null
    }
  }

  phase2_vm_sizes = {
    nix  = "Standard_D8als_v6"
    npcs = "Standard_D16als_v6"
    file = "Standard_D4as_v6"
  }

  nic_names = {
    nix  = "nic-${local.project}-${local.region_code}-nix-01"
    npcs = "nic-${local.project}-${local.region_code}-npcs-01"
    file = "nic-${local.project}-${local.region_code}-file-01"
  }

  data_disk_specs = {
    nix-1 = {
      vm_key               = "nix"
      name                 = "disk-${local.project}-${local.region_code}-nix-data-01"
      storage_account_type = "PremiumV2_LRS"
      size_gb              = 300
      iops                  = 3000
      mbps                  = 125
      tier                  = null
      lun                   = 0
      caching               = "None"
    }

    npcs-1 = {
      vm_key               = "npcs"
      name                 = "disk-${local.project}-${local.region_code}-npcs-data-01"
      storage_account_type = "PremiumV2_LRS"
      size_gb              = 150
      iops                  = 8000
      mbps                  = 125
      tier                  = null
      lun                   = 0
      caching               = "None"
    }

    file-1 = {
      vm_key               = "file"
      name                 = "disk-${local.project}-${local.region_code}-file-data-01"
      storage_account_type = "StandardSSD_LRS"
      size_gb              = try(var.config.compute.file_data_disk_size_gb, 0)
      iops                  = null
      mbps                  = null
      tier                  = null
      lun                   = 0
      caching               = try(var.config.compute.file_data_disk_caching, "")
    }
  }

  private_dns_zones = merge(
    {
      vault    = "privatelink.vaultcore.azure.net"
      blob     = "privatelink.blob.core.windows.net"
      queue    = "privatelink.queue.core.windows.net"
      monitor  = "privatelink.monitor.azure.com"
      oms      = "privatelink.oms.opinsights.azure.com"
      ods      = "privatelink.ods.opinsights.azure.com"
      agentsvc = "privatelink.agentsvc.azure-automation.net"
    },

    {
      for key, zone in {
        backup = try(var.config.private_dns.backup_zone, "")
      } : key => zone

      if try(var.config.private_dns.backup_zone, "") != ""
    },

    {
      for key, zone in {
        internal = try(var.config.private_dns.internal_zone, "")
      } : key => zone

      if try(var.config.private_dns.internal_zone, "") != ""
    }
  )
}

check "base_cidrs" {
  assert {
    condition = (
      local.subnet_cidrs.gateway == "172.16.0.0/27" &&
      local.subnet_cidrs.appgw == "172.16.8.0/24" &&
      local.subnet_cidrs.dns_inbound == "172.16.0.32/28" &&
      local.subnet_cidrs.web == "172.16.16.0/27" &&
      local.subnet_cidrs.pe == "172.16.16.32/27" &&
      local.subnet_cidrs.app == "172.16.16.64/27"
    )

    error_message = "The current IWMF2 subnet logic is tied to the approved Hub 172.16.0.0/20 and Spoke 172.16.16.0/20 layout. If base CIDRs change, review the cidrsubnet net numbers before deployment."
  }
}

check "private_endpoint_inputs" {
  assert {
    condition = (
      !try(var.config.features.private_endpoints, false) ||
      contains(
        ["Enabled", "Disabled"],
        try(var.config.network.pe_network_policies, "")
      )
    )

    error_message = "Private Endpoints are enabled but network.pe_network_policies is not explicitly set to Enabled or Disabled."
  }
}

check "monitoring_inputs" {
  assert {
    condition = !try(var.config.features.monitoring, false) || (
      try(var.config.monitoring.log_analytics_sku, "") != "" &&
      length(try(var.config.monitoring.email_receivers, {})) > 0
    )

    error_message = "Monitoring is enabled but Log Analytics SKU or Action Group email receiver(s) are not populated."
  }
}

check "application_gateway_dependencies" {
  assert {
    condition = !try(var.config.features.application_gateway, false) || (
      try(var.config.features.platform_services, true) &&
      try(var.config.features.compute, false)
    )

    error_message = "Application Gateway deployment requires platform_services and compute to be enabled so Key Vault/UAMI and the NIX backend exist."
  }
}

check "application_gateway_inputs" {
  assert {
    condition = !try(var.config.features.application_gateway, false) || (
      length(local.appgw_sources) > 0 &&
      length(try(var.config.app_gateway.public_fqdns, [])) > 0 &&
      try(var.config.app_gateway.private_fqdn, "") != "" &&
      try(var.config.app_gateway.health_probe_path, "") != "" &&
      try(var.config.app_gateway.autoscale_max, 0) >= 2 &&
      try(var.config.app_gateway.request_timeout_seconds, 0) > 0 &&
      try(var.config.app_gateway.connection_drain_timeout_seconds, 0) > 0 &&
      try(var.config.app_gateway.max_request_body_size_kb, 0) >= 8 &&
      try(var.config.app_gateway.file_upload_limit_mb, 0) >= 1
    )

    error_message = "Application Gateway is enabled but build-gate inputs are incomplete: sources, FQDNs/SNI, health path, autoscale max, backend timeout/drain timeout, or WAF body/upload limits."
  }
}

check "compute_inputs" {
  assert {
    condition = !try(var.config.features.compute, false) || (
      try(var.config.compute.source_image_id, "") != "" &&
      #try(var.config.compute.image_sku, "") != "" &&
      try(var.config.compute.admin_username, "") != "" &&
      try(var.secrets.vm_admin_password, "") != "" &&
      try(var.config.compute.file_os_disk_size_gb, 0) > 0 &&
      contains(
        ["ReadOnly", "ReadWrite", "None"],
        try(var.config.compute.file_os_disk_caching, "")
      ) &&
      try(var.config.compute.file_data_disk_size_gb, 0) > 0 &&
      contains(
        ["ReadOnly", "ReadWrite", "None"],
        try(var.config.compute.file_data_disk_caching, "")
      )
    )

    error_message = "Compute is enabled but one or more build-gate inputs are missing: Azure Compute Gallery image version ID, admin username/password, or final File Server OS/data disk size/caching values."
  }
}

check "s2s_inputs" {
  assert {
    condition = !try(var.config.s2s.enabled, false) || (
      try(var.config.s2s.office_public_ip, "") != "" &&
      length(try(var.config.s2s.office_prefixes, [])) > 0 &&
      try(var.secrets.s2s_shared_key, "") != ""
    )

    error_message = "S2S is enabled but office public IP, office prefixes or secret s2s_shared_key is missing."
  }
}

check "vpn_dependency" {
  assert {
    condition = (
      !try(var.config.s2s.enabled, false) &&
      !try(var.config.p2s.enabled, false)
    ) || try(var.config.features.vpn_gateway, false)

    error_message = "S2S/P2S is enabled but features.vpn_gateway is false."
  }
}

check "p2s_inputs" {
  assert {
    condition = !try(var.config.p2s.enabled, false) || (
      local.p2s_cidr != null &&
      contains(
        ["entra", "aad", "certificate", "radius"],
        lower(try(var.config.p2s.authentication, ""))
      ) &&
      (
        !contains(
          ["entra", "aad"],
          lower(try(var.config.p2s.authentication, ""))
        ) ||
        (
          try(var.config.p2s.aad_audience, "") != "" &&
          try(var.config.p2s.aad_issuer, "") != ""
        )
      ) &&
      (
        lower(try(var.config.p2s.authentication, "")) != "certificate" ||
        length(try(var.config.p2s.root_certificates, {})) > 0
      ) &&
      (
        lower(try(var.config.p2s.authentication, "")) != "radius" ||
        (
          try(var.config.p2s.radius_server_address, "") != "" &&
          try(var.secrets.p2s_radius_secret, "") != ""
        )
      )
    )

    error_message = "P2S is enabled but client CIDR/authentication inputs are incomplete. Entra requires audience+issuer; Certificate requires a root certificate; RADIUS requires server address+secret."
  }
}
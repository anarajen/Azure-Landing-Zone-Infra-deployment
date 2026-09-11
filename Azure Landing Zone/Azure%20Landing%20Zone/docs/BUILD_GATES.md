# IWMF2 Build-Gate Inputs

Populate only values that have been approved, then set the corresponding feature flag in `environments/prod/terraform.tfvars`.

| Feature | Required input before enabling |
|---|---|
| Base network | Hub/Spoke CIDRs, subscription, tenant, region (already populated) |
| DNS-dependent rules | customer primary/secondary DNS IPs |
| S2S | office VPN public IP, office CIDRs, BGP values if used, approved IPsec policy if custom, `S2S_SHARED_KEY` secret |
| P2S | auth model; Entra audience+issuer, or root cert, or RADIUS server+secret; overlap confirmation for `10.100.0.0/24` |
| Compute | ACG image version resource ID, admin username, `VM_ADMIN_PASSWORD`, File OS/data disk size+caching |
| Application Gateway | source CIDRs, public FQDN, NIX private FQDN/SNI, health path, Key Vault versionless secret URI, autoscale max, backend timeout, connection drain timeout, WAF request body/upload limits |
| Private Endpoints | explicit PE network-policy mode and regional Backup zone if Backup PE is enabled |
| Monitoring | LAW SKU and Action Group receiver(s); metric-alert map if alerts are enabled |
| Backup | backup time and daily retention count; regional Backup Private DNS zone when private endpoint is used |
| Maintenance | start date/time, duration and recurrence |
| Budget | approved amount, start/end dates and recipients |
| Policy | approved assignment/initiative IDs and scopes |
| Bastion | commercial/scope approval and approved AzureBastionSubnet CIDR |
| DDoS IP Protection | Security/FinOps approval before enabling billable IP protection |

## Secrets

Never place these values in `.tfvars`:

- VM local administrator password
- S2S PSK
- RADIUS shared secret
- private-CA trusted root certificate data if required

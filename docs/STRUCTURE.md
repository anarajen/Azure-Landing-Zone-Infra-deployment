# Code structure

```text
root
├── backend.tf
├── providers.tf
├── versions.tf
├── variables.tf
├── main.tf                  # only module "logic"
├── outputs.tf
├── environments/prod
│   ├── backend.hcl
│   └── terraform.tfvars     # one config map, minimum inputs
├── modules
│   ├── logic                # all naming/CIDR/maps/for_each/child calls
│   ├── resource-group
│   ├── virtual-network
│   ├── subnet
│   ├── network-security-group
│   ├── vnet-peering
│   ├── public-ip
│   ├── nat-gateway
│   ├── virtual-network-gateway
│   ├── local-network-gateway
│   ├── vpn-connection
│   ├── application-gateway
│   ├── waf-policy
│   ├── network-interface
│   ├── windows-vm
│   ├── managed-disk
│   ├── disk-performance-tier
│   ├── key-vault
│   ├── storage-account
│   ├── recovery-services-vault
│   ├── private-dns-zone
│   ├── private-endpoint
│   ├── log-analytics
│   ├── monitor-private-link-scope
│   ├── data-collection-rule
│   ├── action-group
│   ├── diagnostic-setting
│   ├── backup-policy-vm
│   ├── maintenance-configuration
│   ├── defender
│   ├── budget
│   ├── policy-assignment
│   └── ... supporting association/extension modules
├── bootstrap
├── pipelines
└── scripts
```

Child modules contain resource implementation only. They do not construct IWMF2 names or calculate IWMF2 network addresses.

# Virtual Network Gateway
import {
  to = module.logic.module.virtual_network_gateway["main"].azurerm_virtual_network_gateway.this
  id = "/subscriptions/0bec3890-91f5-46f9-954a-434049775d9a/resourceGroups/rg-iwmf-sea-hub-01/providers/Microsoft.Network/virtualNetworkGateways/vng-iwmf-sea-hub-01"
}

# Local Network Gateway (office)
import {
  to = module.logic.module.local_network_gateway["office"].azurerm_local_network_gateway.this
  id = "/subscriptions/0bec3890-91f5-46f9-954a-434049775d9a/resourceGroups/rg-iwmf-sea-hub-01/providers/Microsoft.Network/localNetworkGateways/lng-iwmf-sea-office-01"
}

# S2S Connection
import {
  to = module.logic.module.s2s_connection["office"].azurerm_virtual_network_gateway_connection.this
  id = "/subscriptions/0bec3890-91f5-46f9-954a-434049775d9a/resourceGroups/rg-iwmf-sea-hub-01/providers/Microsoft.Network/connections/s2s-vpn-01"
}

import {
  to = module.logic.module.public_ips["smtp"].azurerm_public_ip.this
  id = "/subscriptions/0bec3890-91f5-46f9-954a-434049775d9a/resourceGroups/rg-iwmf-sea-hub-01/providers/Microsoft.Network/publicIPAddresses/pip-iwmf-sea-smtp-01"
}
import {
  to = module.logic.module.smtp_load_balancer["main"].azurerm_lb.this
  id = "/subscriptions/0bec3890-91f5-46f9-954a-434049775d9a/resourceGroups/rg-iwmf-sea-hub-01/providers/Microsoft.Network/loadBalancers/elb-iwmf-sea-smpt-01"
}
import {
  to = module.logic.module.smtp_load_balancer["main"].azurerm_lb_backend_address_pool.this
  id = "/subscriptions/0bec3890-91f5-46f9-954a-434049775d9a/resourceGroups/rg-iwmf-sea-hub-01/providers/Microsoft.Network/loadBalancers/elb-iwmf-sea-smpt-01/backendAddressPools/bpool-smtp-01"
}
import {
  to = module.logic.module.smtp_load_balancer["main"].azurerm_lb_probe.this
  id = "/subscriptions/0bec3890-91f5-46f9-954a-434049775d9a/resourceGroups/rg-iwmf-sea-hub-01/providers/Microsoft.Network/loadBalancers/elb-iwmf-sea-smpt-01/probes/hp-iwmf-sea-smtp-25"
}
import {
  to = module.logic.module.smtp_load_balancer["main"].azurerm_lb_rule.this
  id = "/subscriptions/0bec3890-91f5-46f9-954a-434049775d9a/resourceGroups/rg-iwmf-sea-hub-01/providers/Microsoft.Network/loadBalancers/elb-iwmf-sea-smpt-01/loadBalancingRules/lbr-iwmf-sea-smtp-25"
}

# NIC <-> SMTP backend pool membership (nix VM in bpool-smtp-01)
import {
  to = module.logic.azurerm_network_interface_backend_address_pool_association.nix_smtp["main"]
  id = "/subscriptions/0bec3890-91f5-46f9-954a-434049775d9a/resourceGroups/rg-iwmf-sea-app-01/providers/Microsoft.Network/networkInterfaces/nic-iwmf-sea-nix-01/ipConfigurations/ipconfig1|/subscriptions/0bec3890-91f5-46f9-954a-434049775d9a/resourceGroups/rg-iwmf-sea-hub-01/providers/Microsoft.Network/loadBalancers/elb-iwmf-sea-smpt-01/backendAddressPools/bpool-smtp-01"
}
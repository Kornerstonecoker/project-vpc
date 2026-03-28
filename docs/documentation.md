Architecture
A hub-spoke network is the standard enterprise pattern in Azure. The idea is simple — one central hub VNet that everything flows through, and spoke VNets for your workloads that connect back to the hub. All internet traffic, firewall inspection, and shared services live in the hub. Spokes never talk to each other directly — traffic always goes hub → spoke or spoke → hub → spoke.
Why hub-spoke? The alternative is a flat VNet where everything lives together. That works for a hobby project but falls apart the moment you need to isolate environments or workloads. Hub-spoke gives you a single place to enforce security (the hub firewall) and clean isolation between spokes.
The three things that make traffic flow correctly:

VNet peering connects each spoke to the hub — but peering is not transitive. Spoke 1 and Spoke 3 cannot talk directly, even though both peer to the hub. Traffic between spokes must route spoke → hub → spoke via the firewall.
User-Defined Routes (UDRs) on every spoke subnet force all outbound traffic (0.0.0.0/0) to the Azure Firewall's private IP. Without UDRs, Azure's default routing would send internet traffic directly out, bypassing the firewall entirely.
NSGs are your per-subnet micro-segmentation. The firewall handles north-south (internet) and east-west (spoke-to-spoke). NSGs handle the granular rules within a subnet — what ports, what sources.

The IP address plan you'll use:
VNetCIDRPurposeHub10.0.0.0/16Shared servicesHub — GatewaySubnet10.0.0.0/27VPN/ER gateway (must be this name)Hub — AzureFirewallSubnet10.0.1.0/26Firewall (must be this name, min /26)Spoke 1 (Dev)10.1.0.0/16Dev workloadsSpoke 2 (Staging)10.2.0.0/16Staging workloadsSpoke 3 (Prod)10.3.0.0/16Production workloads


The spoke module gets called three times — once for dev, staging, and prod — passing in different CIDRs and NSG rules. This is the module pattern in practice.
Ready to start writing the Terraform? We'll go file by file, starting with the hub module since everything else depends on it.


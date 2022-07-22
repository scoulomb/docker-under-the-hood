# NAT

## DNAT and SNAT 

https://networkinterview.com/snat-vs-dnat/

SNAT i.e. Source Network Address Translation as the name implies involves the translation of source IP address. Thus it allows the internal host to connect with the internet by translating its private IP address to public IP address. (normal internet browsing)

DNAT i.e. Destination Network Address Translation is used by an external host to initiate connection with a private network. So, it translates the public IP address of an external host to the private IP of internal Host. (if hosting a webserver @home, SFR box v8 => http://192.168.1.1/network/nat)

Also check

- https://networkinterview.com/nat-type-1-vs-2-vs-3-detailed-comparison/ (note link with [NAS](#other-examples), for UPNP discovery of port and ps4)
- https://networkinterview.com/nat-configuration-nat-types-palo-alto/

## Example of Docker iptables

Used to NAT traffic between host and container (2 linux net namespaces).
See [container under the hood](container-under-the-hood-link-snat-dnat.md).

## Firewall (example of Azure firewall)

### DNAT

AZ900 book, p213 (similar to https://docs.microsoft.com/en-us/azure/firewall/tutorial-firewall-deploy-portal-policy#create-a-default-route without [hub and spoke](https://github.com/scoulomb/myPublicCloud/blob/master/Azure/Networking/basic.md#hub-spoke-network-topology)).

Both Outbound and Inbound traffic to go through firewall via route
<!-- p217, this will ensure that the firewall will handle all the network traffic to the jumpbox VM and all traffic from server subnet -->

For Inbound traffic (to connect via remote desktop to Jumpbox VM), we setup a DNAT rule
https://docs.microsoft.com/en-us/azure/firewall/tutorial-firewall-dnat-policy


### SNAT 

Quoting doc about SNAT private IP address ranges: https://github.com/MicrosoftDocs/azure-docs/blob/main/articles/firewall/snat-private-range.md

> Azure Firewall provides automatic SNAT for all outbound traffic to public IP addresses. By default, Azure Firewall doesn't SNAT with Network rules when the destination IP address is in a private IP address range per [IANA RFC 1918](https://tools.ietf.org/html/rfc1918) or shared address space per [IANA RFC 6598](https://tools.ietf.org/html/rfc6598). Application rules are always applied using a [transparent proxy](https://wikipedia.org/wiki/Proxy_server#Transparent_proxy) whatever the destination IP address.

> This logic works well when you route traffic directly to the Internet. However, if you've enabled [forced tunneling](forced-tunneling.md), Internet-bound traffic is SNATed to one of the firewall private IP addresses in AzureFirewallSubnet, hiding the source from your on-premises firewall.

> If your organization uses a public IP address range for private networks, Azure Firewall SNATs the traffic to one of the firewall private IP addresses in AzureFirewallSubnet. However, you can configure Azure Firewall to **not** SNAT your public IP address range. For example, to specify an individual IP address you can specify it like this: `192.168.1.10`. To specify a range of IP addresses, you can specify it like this: `192.168.1.0/24`.

> - To configure Azure Firewall to **never** SNAT regardless of the destination IP address, use **0.0.0.0/0** as your private IP address range. With this configuration, Azure Firewall can never route traffic directly to the Internet. 

> - To configure the firewall to **always** SNAT regardless of the destination address, use **255.255.255.255/32** as your private IP address range.


Note Firewall usually do SNAT ([palo alto](https://networkinterview.com/nat-configuration-nat-types-palo-alto/), cisco, [Fortinet](https://docs.fortinet.com/document/fortigate/6.2.0/cookbook/898655/static-snat)).
But also F5: https://support.f5.com/csp/article/K47945399, which also even offers SNAT pool (many to many NAT type: https://networkinterview.com/nat-configuration-nat-types-palo-alto/ )

Transparent SNAT: ESB/appli targets external/provider ip, Routing rule to F5 or Firewall and firewall/f5 change source ip (private ip to public). Provider sees public IP (transparent proxy)

<!--
Explicit SNAT: ESB targets f5 vip (private ip), and F5 has  pool member to provider/external IP, provider see F5 public IP -
Except if firewall renatting F5 IP - In that case no big added value (for removal) to move to transparent
-->

## Other examples

We have seen good example of NAT here
- NAT/upnp in access provider box (for NAS access): https://github.com/scoulomb/misc-notes/blob/master/NAS-setup/README.md
- [Docker natting](/container-under-the-hood-link-snat-dnat.md)
- Azure Firewall can do SNAT/DNAT (see AZ900)
- SNAT/DNAT at k8s service level: https://github.com/scoulomb/myk8s/blob/master/Services/service_deep_dive.md#nat

<!-- ok ccl -->
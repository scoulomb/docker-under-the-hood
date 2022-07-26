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

p219: NAT rule conllection is DNAT, see SNAT in [SNAT below section](#snat)


<!-- az900, p213, Azure firewall concluded -->

### SNAT 

Quoting doc about SNAT private IP address ranges: https://github.com/MicrosoftDocs/azure-docs/blob/main/articles/firewall/snat-private-range.md

> Azure Firewall provides automatic SNAT for all outbound traffic to public IP addresses. By default, Azure Firewall doesn't SNAT with Network rules when the destination IP address is in a private IP address range per [IANA RFC 1918](https://tools.ietf.org/html/rfc1918) or shared address space per [IANA RFC 6598](https://tools.ietf.org/html/rfc6598). Application rules are always applied using a [transparent proxy](https://wikipedia.org/wiki/Proxy_server#Transparent_proxy) whatever the destination IP address.

> This logic works well when you route traffic directly to the Internet. However, if you've enabled [forced tunneling](forced-tunneling.md), Internet-bound traffic is SNATed to one of the firewall private IP addresses in AzureFirewallSubnet, hiding the source from your on-premises firewall.

> If your organization uses a public IP address range for private networks, Azure Firewall SNATs the traffic to one of the firewall private IP addresses in AzureFirewallSubnet. However, you can configure Azure Firewall to **not** SNAT your public IP address range. For example, to specify an individual IP address you can specify it like this: `192.168.1.10`. To specify a range of IP addresses, you can specify it like this: `192.168.1.0/24`.

> - To configure Azure Firewall to **never** SNAT regardless of the destination IP address, use **0.0.0.0/0** as your private IP address range. With this configuration, Azure Firewall can never route traffic directly to the Internet. 

> - To configure the firewall to **always** SNAT regardless of the destination address, use **255.255.255.255/32** as your private IP address range.


Note Firewall usually do SNAT ([palo alto](https://networkinterview.com/nat-configuration-nat-types-palo-alto/), cisco, [Fortinet](https://docs.fortinet.com/document/fortigate/6.2.0/cookbook/898655/static-snat)).
But also F5: https://support.f5.com/csp/article/K47945399, which also even offers SNAT pool (many to many NAT type: https://networkinterview.com/nat-configuration-nat-types-palo-alto/ )

**Transparent SNAT**: 
ESB/appli targets external/provider ip -> L4 FW (us) Routing rule to F5 or Firewall and firewall/f5 change source ip (private ip to public ip via SNAT pool) -> FW (ext provider) -> SVC provider (provider sees public IP)

L7 firewall (should also allow NAT)T: https://serverfault.com/questions/792572/what-does-a-layer-3-4-firewall-do-that-a-layer-7-does-not

See also F5 SNAT:
- https://support.f5.com/csp/article/K47945399
    - Standard SNAT: many to one (https://networkinterview.com/nat-configuration-nat-types-palo-alto/)
    - Automap SNAT: many to many
    - SNAT pools: many to many
- SNAT pool: https://support.f5.com/csp/article/K47945399


<!--
**Explicit SNAT**:
ESB/appli targets F5 vip (private ip) -> and F5 has pool member to provider/external IP  -> provider see F5 public IP.
Except if firewall renatting F5 IP - In that case no big added value (for removal) to move to transparent
-->

We can also rely on a treansparent proxy for web caching, it relies on WCCP: https://en.wikipedia.org/wiki/Web_Cache_Communication_Protocol
Trasmparent proxy can also
- Hide from customer complexity of infra (modify source source IP) => SNAT
    - https://www.stux6.net/unix/linux/proxy-transparent-linux-squid
- Performs IP whitlesting to external
There is overlapp between firewall and proxy: https://waytolearnx.com/2018/09/difference-entre-proxy-et-firewall.html
See https://github.com/scoulomb/misc-notes/tree/master/replicate-k8s-ingress-locally-with-compose#squid-proxy-firewall-open 
<!-- [Link 1]: ~~ SNAT 1A ~~ [replicate-k8s-ingress-locally-with-compose] -->

Even big ip offers WCCP: https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-11-6-0/13.html

Sometimes those proxy makes also certificate shaddowing.

<!-- not sfr box nat rule in ipv4 become firewall in ipv6 ! -->

<!-- See private_script: Links-mig-auto-cloud/README.md#outbound-links [Link 2]: ~~ SNAT 1A ~~ [Certificate] --> 

### In IPV6 how can I add my internal IPs?

Quoting:
> IPv6 was originally designed to work without NAT. That all changed around 2010 with the introduction of NAT66 and NPT66. 

From https://www.ietf.org/archive/id/draft-mrw-nat66-00.html
> This document describes a stateless, transport-agnostic IPv6-to-IPv6 Network Address Translation (NAT66) function that provides the address independence benefit associated with IPv4-to-IPv4 NAT (NAT44) while minimizing, but not completely eliminating, the problems associated with NAT44. 

From https://www.cisco.com/c/en/us/td/docs/ios-xml/ios/ipaddr_nat/configuration/xe-16-10/nat-xe-16-10-book/iadnat-asr1k-nptv6.html
> The NPTv6 support on ASR1k/CSR1k/ISR4k feature supports IPv6-to-IPv6 Network Prefix Translation (NPTv6) which enables a router to translate an IPv6 packet header to IPv6 packet header and vice versa. The IPv6-to-IPv6 Network Prefix Translation (NPTv6) provides a mechanism to translate an inside IPv6 source address prefix to outside IPv6 source address prefix in IPv6 packet header and vice-versa. A router that implements an NPTv6 prefix translation function is referred to as an NPTv6 Translator. 


## Other examples

We have seen good example of NAT here
- NAT/upnp in access provider box (for NAS access): https://github.com/scoulomb/misc-notes/blob/master/NAS-setup/README.md
- [Docker natting](/container-under-the-hood-link-snat-dnat.md)
- Azure Firewall can do SNAT/DNAT (see AZ900)
- SNAT/DNAT at k8s service level: https://github.com/scoulomb/myk8s/blob/master/Services/service_deep_dive.md#nat

<!-- ok ccl, SNAT CCL -->
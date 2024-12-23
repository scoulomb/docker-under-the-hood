# NAT deep dive

I also recommend to read [Tanenbaum, Reseau 5eme edition] chapitre 5, La couche reseau, section 5.6: Couche reseau dans l'Internet (p465)

## Quoting Tanenbaum 

It only mentions S(ource)NAT.

[From Tanenbaum, Reseau 5eme edition] chapitre 5, La couche reseau, section 5.6: Couche reseau dans l'Internet (p465), Traduction d'adresse de reseau (NAT) (p481), p483

![NAT](media/Reseau-5ed-Figure5-55-nat-20220808_162654.jpg)

<!-- use OCR app -->

> Voici la demarche qu'ont suivie les concepteurs de NAT.
Ils ont remarqué que |a majorite des paquets IP incluent une charge utile TCP ou UDP.
Nous verrons au **chapitre 6 {page 576 et 592} que len-tete de ces deux protocoles contient un champ de port source et un champ de port de destination.** 
NAT s’appuie dessus pour fonctionner. L'explication qui suit prend pour exemple TCP, mais elle s’applique tout aussi bien a UDP.



> Lorsqu'un processus souhaite établir une connexion TCP avec un processus distant, 
Il s'attache a un port TCP sur la machine locale, appelé port TCP source.
Ce port indique au code TCP vers quel processus diriger les paquets TCP entrants sur cette connexion.
Le processus local désigne également un port TCP de destination qui specifie le processus auquel remettre les paquets
une fois qu ils sont arrivés sur I’hote distant.
Les numéros 0 a 1 023 correspondent a des ports réservés.
Par exemple, le port 80 est utilisé par les serveurs web pour permettre aux clients distants de les localiser. 
Chaque message TCP renferme un numéro de port source et un numéro de port de destination.
Les numéros de ports sont des entiers codés sur 16 bits qui identifient les processus aux deux extrémités d’une connexion.

> Pour mieux comprendre l'utilité des ports, procédons par analogie.
Imaginons une société qui dispose d’un numéro de téléphone principal. Lorsque des personnes composent ce numero,
elles obtiennent une standardiste qui leur demande le numéro du poste de leur interlocuteur et les met en contact.
Le numéro principal est semblable al’adresse IP du client, et les extensions des deux interlocuteurs sont analogues aux numéros de ports. Les ports constituent en fait un adressage sur 16 bits supplémentaire qui identifie les processus recevant le paquet entrant.

> Revenons-en maintenant au fonctionnement de NAT.
Lorsqu’un paquet envoyé en sortie arrive sur le dispositif NAT, 
l’adresse source 10.x.y.z. est remplacée par l’adresse IP du client.
De plus, le champ Port source TCP est remplacé par une référence a une entrée de la table de traduction de 65 536 adresses du dispositif NAT.
Cette **entrée inclut l'adresse IP et le port source d’origine**. 
Ensuite, les totaux de controle IP et TCP sont recalculés et insérés dans le paquet. 
**Il est nécessaire de remplacer le champ Port source. En effet, les machines 10.0.0.1 et 10.0.0.2,
par exemple, pourraient toutes deux avoir initié une connexion sur le port 5000, auquel cas le numéro port source ne suffrait pas pour identifier le processus émetteur.**


> **Lorsqu’un paquet arrive sur le dispositif NAT en provenance du FAI, le champ Port source de l’en-téte TCP est extrait et utilisé comme pointeur dans la table de correspondances du dispositif NAT. Une fois l’entrée correspondante localisée, l’adresse IP interne et le champ Port source TCP dorigine indiqués sont récupérés et insérés dans le paquet.**
Les totaux de contréle sont aussi recalculés. Le paquet est ensuite transmis au routeur du client qui le remet a l’adresse 10.x.y.Z..approprice.

> **NAT peut aussi servir a pallier le manque d’adresses IP pour les utilisateurs service ADSL et du cable.
Le FAI assigne alors une adresse 10.x.y.27 a un dad abonne.
Lorsque les paquets de ces utilisateurs quittent le site du FAI pour entrer sur l’'Internet, 
ils passent par un dispositif NAT qui leur applique l’adresse IP du FAI.**



Let's go further

## Prereq and TCP/UDP Source port

Read https://github.com/scoulomb/misc-notes/blob/master/NAS-setup/Wake-On-LAN.md
And all section marked as 
`[From Tanenbaum, Reseau 5eme edition] chapitre 5, La couche reseau, section 5.6: Couche reseau dans l'Internet (p465)....`


Note that source port (used by NAT) is usually randomly chosen by OS but can enforce it
From  
- https://stackoverflow.com/questions/2694212/python-set-source-port-number-with-sockets,
- https://stackoverflow.com/questions/40971040/specifying-source-ip-address-for-socket-connect-in-python-sockets
Use `socket.bind((ipaddr, port))` 

For instance here https://github.com/scoulomb/http-over-socket/tree/main/1-client

A fw rule is usually (source ip, dest ip, dest port). But could have source port.

For example we can observe a request to github.
Go to Wireshark, shoot github.
Filter `ip.src==192.168.1.90 and ip.dst==140.82.121.4`

Where `ip.src` is laptop IP on LAN and `ip.dst` is 
````
scoulomb@scoulomb-HP-Pavilion-TS-Sleekbook-14:~$ nslookup 140.82.121.4
4.121.82.140.in-addr.arpa name = lb-140-82-121-4-fra.github.com.
````

And `File` > `Export packet dissection` > `As plain text` [here](media/github-export.txt).

Let's take a frame (see comment `#`)

`````shell
No.     Time           Source                Destination           Protocol Length Info
    124 2.790396401    192.168.1.90          140.82.121.4          TCP      66     47030 → 443 [ACK] Seq=1293 Ack=2973 Win=64128 Len=0 TSval=2610848394 TSecr=4212279757

Frame 124: 66 bytes on wire (528 bits), 66 bytes captured (528 bits) on interface wlo1, id 0
Ethernet II, Src: LiteonTe_c5:99:c1 (20:68:9d:c5:99:c1), Dst: Sfr_62:df:48 (e4:5d:51:62:df:48)
    Destination: Sfr_62:df:48 (e4:5d:51:62:df:48)   
    
    # Ethernet Layer, we target the BOX IP
    # See https://github.com/scoulomb/misc-notes/blob/master/NAS-setup/Wake-On-LAN.md#reminder-on-arp
    # Case where Ethernet address is not in LAN and accumulation with NAT
    # We have DNS query, ARP request and NAT table updated, then TLS (client hello) and OCSP (https://github.com/scoulomb/misc-notes/tree/master/tls) via NAT betwen box and github endpoint 
    # Github endpoint can have load lancer with fw in front, and router in between (with intermediate NAT).
    # see Link with private_script/tree/main/Links-mig-auto-cloud - stop diving
    
    Source: LiteonTe_c5:99:c1 (20:68:9d:c5:99:c1)   
    
    # Laptop Ethernet card mac
    
    Type: IPv4 (0x0800)
Internet Protocol Version 4, Src: 192.168.1.90, Dst: 140.82.121.4

    # Can see source IP laptop which will be Natted
    
    0100 .... = Version: 4
    .... 0101 = Header Length: 20 bytes (5)
    Differentiated Services Field: 0x00 (DSCP: CS0, ECN: Not-ECT)
    Total Length: 52
    Identification: 0x77e9 (30697)
    Flags: 0x40, Don't fragment
    Fragment Offset: 0
    Time to Live: 64
    Protocol: TCP (6)
    Header Checksum: 0xfb81 [validation disabled]
    [Header checksum status: Unverified]
    Source Address: 192.168.1.90
    Destination Address: 140.82.121.4
Transmission Control Protocol, Src Port: 47030, Dst Port: 443, Seq: 1293, Ack: 2973, Len: 0
    Source Port: 47030
    Destination Port: 443
    
    # Here we are Source Port and Destination Port
    # Will be used to build the NAT table, See figure 5.55
    # Even when NAT is not masquerade (as in Docker), this mapping is not visible directly, --to-source is the range for natting (many to many) https://www.inetdoc.net/guides/iptables-tutorial/snattarget.html
    
    [Stream index: 3]
    [TCP Segment Len: 0]
    Sequence Number: 1293    (relative sequence number)
    Sequence Number (raw): 4251858603
    [Next Sequence Number: 1293    (relative sequence number)]
    Acknowledgment Number: 2973    (relative ack number)
    Acknowledgment number (raw): 2569120225
    1000 .... = Header Length: 32 bytes (8)
    Flags: 0x010 (ACK)
    Window: 501
    [Calculated window size: 64128]
    [Window size scaling factor: 128]
    Checksum: 0x39d7 [unverified]
    [Checksum Status: Unverified]
    Urgent Pointer: 0
    Options: (12 bytes), No-Operation (NOP), No-Operation (NOP), Timestamps
    [SEQ/ACK analysis]
    [Timestamps]
`````

Then here we explained how [Ethernet frame](https://en.wikipedia.org/wiki/Ethernet_frame) is received: https://github.com/scoulomb/misc-notes/blob/master/NAS-setup/Wake-On-LAN.md#reminder-on-arp
>  Maintenant que le logiciel IP de l’hote 1 détient l'adresse Ethernet de l’hote 2, ....
Where is the IP is not in the LAN.

We can see source IP in TCP/(UDP) datagram encapsulated in ethernet frame.
See https://stackoverflow.com/questions/31446777/difference-between-packets-and-frames/31464376#31464376

This source port can also be seen [Wake on LAN request](https://github.com/scoulomb/misc-notes/blob/master/NAS-setup/Wake-On-LAN.md#wol---how-does-it-work) as explained in that section.
<!-- OK -->
Example given in this [link](https://github.com/scoulomb/misc-notes/blob/master/NAS-setup/media/wireshark-export-android-wol-192-168-1-255.txt).

<!--
p474
Division de prefixe IP (apply mask to know to which network to route)
p477 (routage CIDR)
aggregation de prefixe IP (entry in route table) et aggregation avec Route la plus specifique, <=> dans celle du plus long prefixe correspondant ayant le moins d'adresse ip,
p504 
Routage intradomaine OSPF (to auto add entty in route table) 
p510
Routage interdomaine BGP (to auto add entry in route table)

private_script/tree/main/Links-mig-auto-cloud, for migration prefix and BGP, do not enter in details stop

-->

## Type of S(ource)NAT

![NAT](media/Reseau-5ed-Figure5-55-nat-20220808_162654.jpg)

From picture we have

|      | Before translation    | After Translation        |
|------|-----------------------|--------------------------|
| IP   | 10.0.0.1 (private IP) | 198.60.42.12 (public IP) |
| Port | 5544                  | 3344                     |


What Kind of (S)ource NAT do we have?

From https://fr.wikipedia.org/wiki/Network_address_translation => https://www.ciscomadesimple.be/2013/04/06/configuration-du-nat-sur-un-routeur-cisco/

and https://www.cisco.com/c/en/us/td/docs/ios-xml/ios/ipaddr/command/ipaddr-cr-book/ipaddr-i3.html#wp1284532593

We will see same pattern is working it can also be applied to
- All kind of SNAT
- DNAT

### Source NAT: Static NAT (one to one)

Quoting  https://www.ciscomadesimple.be/2013/04/06/configuration-du-nat-sur-un-routeur-cisco/ (forked [here](media/configuration-du-nat-sur-un-routeur-cisco/configuration-du-nat-sur-un-routeur-cisco.htm))

>  Nous allons explicitement indiquer au routeur que ce qui arrive sur son interface publique (S0/0) et dont l’adresse destination est 201.49.10.30 (une des adresse du pool publique) doit être redirigé vers 192.168.1.100.

See DNAT [below](#what-about-destination-nat).

> Du point de vue du routeur cela revient à modifier l’adresse IP destionation dans l’en-tête IPv4 avant de router le paquet. Cela signifie aussi que si C3 envoi un paquet vers internet, à la sortie de S0/0 de R1 l’adresse source (192.168.1.100) sera remplacée par l’adresse indiquée dans la translation, soit 201.49.10.30.

````
R1(config)#ip nat inside source static 192.168.1.100 201.49.10.30
````

In [Ciso doc](https://www.cisco.com/c/en/us/td/docs/ios-xml/ios/ipaddr/command/ipaddr-cr-book/ipaddr-i3.html#wp1284532593) this is 

````
ip nat inside source/Static NAT

ip nat inside source static {esp local-ip interface type number | local-ip global-ip} [extendable] [no-alias] [no-payload] [route-map name [reversible]] [redundancy {group-name | rg-id mapping-id mapping-id}] [reversible] [vrf name [match-in-vrf] [forced]]

````
We can also have port static NAT. 
In [Ciso doc](https://www.cisco.com/c/en/us/td/docs/ios-xml/ios/ipaddr/command/ipaddr-cr-book/ipaddr-i3.html#wp1284532593) this is 

````
ip nat inside source/Port Static NAT

ip nat inside source static {tcp | udp} {local-ip local-port global-ip global-port [extendable] [forced] [no-alias] [no-payload] [redundancy {group-name | rg-id mapping-id mapping-id}] [route-map name [reversible]] [vrf name [match-in-vrf]] | interface global-port} 
````


### Source NAT: NAT with pool of address (many to many)

#### Simple 

Quoting  https://www.ciscomadesimple.be/2013/04/06/configuration-du-nat-sur-un-routeur-cisco/


> Ici, au lieu de configurer une translation statique, nous allons donner au routeur une plage d’adresses publiques (un pool d’adresse) dans laquelle il peut piocher pour créer dynamiquement les translations

````
# Tout d’abord créons le pool d’adresses
R1(config)#ip nat pool POOL-NAT-LAN2 201.49.10.17 201.49.10.30 netmask 255.255.255.240
# Il nous faut ensuite définir quelles adresses IP sources seront susceptibles d’êtres translatées … pour cela il faut créer une ACL.
R1(config)#access-list 1 deny 192.168.1.100
R1(config)#access-list 1 permit 192.168.1.0 0.0.0.255
# Il ne reste plus qu’à configurer le NAT en lui même

R1(config)#ip nat inside source list 1 pool POOL-NAT-LAN2

# On instruit donc ici le routeur de créer dynamiquement une translation pour les paquets arrivant sur une interface « inside » routés par une interface « outside » dont l’adresse IP source correspond à l’ACL 1 et de remplacer l’IP source par une de celles comprises dans le pool POOL-NAT-LAN2.
````


In [Ciso doc](https://www.cisco.com/c/en/us/td/docs/ios-xml/ios/ipaddr/command/ipaddr-cr-book/ipaddr-i3.html#wp1284532593) this is 

````
ip nat inside source/Dynamic NAT

ip nat inside source {list {access-list-number | access-list-name} | route-map name} {interface type number | pool name [redundancy rg-id mapping-id mapping-id]} [no-payload] [overload] [c] [vrf name [match-in-vrf]] [oer] [portmap name] 
````

Where `pool name` is used 


#### Overload - PAT


Quoting  https://www.ciscomadesimple.be/2013/04/06/configuration-du-nat-sur-un-routeur-cisco/
> **Attention, si il y a plus de machine dans le réseau privé que d’adresses publiques disponibles, il faut alors rajouter le mot clé « overload » à la commande:**

````

R1(config)#ip nat inside source list 1 pool POOL-NAT-LAN2 overload

# Ceci permet de « partager » les adresses publiques en translatant également les numéros de ports dans l’entête de la couche transport (méthode communément appelée PAT).
# For me it si the biggest advantage of NAT

````

This is the nominal case of Tanenbaum.

#### Configuration du NAT dynamique avec surcharge (sans pool) (many to one) with Overload - PAT

Quoting  https://www.ciscomadesimple.be/2013/04/06/configuration-du-nat-sur-un-routeur-cisco/

> Il reste encore à configurer R2 pour que le réseau 192.168.0.0/24 puisse accéder à l’extérieur. Pour cela nous allons configurer le troisième type de NAT, à savoir du NAT dynamique avec surcharge (overload) en utilisant l’adresse publique configurée sur l’interface S0/0 de R1.

> Notez que c’est la configuration la plus courante dans un réseau modeste (par exemple dans un réseau domestique). Cette méthode ne requiert pas d’obtenir de nouvelles adresses publiques auprès du provider.

> Nous devons cette fois aussi identifier les adresses sources à faire passer par le NAT, donc nous créons une nouvelle ACL.

````
R1(config)#access-list 2 permit 192.168.0.0 0.0.0.255
````

Il ne reste plus qu’à configurer le NAT.

````
R1(config)#ip nat inside source list 2 interface serial 0/0 overload
````


Nous disons ici au routeur de translater les paquets provenant des adresses décrites dans l’ACL 2 (192.168.0.0/24) et de remplacer l’adresse IP source par celle configurée sur l’interface Serial 0/0 en la surchargeant pour permettre à plus d’une machine de communiquer avec l’extérieur (PAT).


In [Cisco doc](https://www.cisco.com/c/en/us/td/docs/ios-xml/ios/ipaddr/command/ipaddr-cr-book/ipaddr-i3.html#wp1284532593) this is also `ip nat inside source/Dynamic NAT` with `interface serial`.

This is also the nominal case of Tanenbaum.

## What about D(estination) NAT

From
- https://www.cisco.com/c/en/us/support/docs/ip/network-address-translation-nat/13772-12.html#topic12 (ip nat inside) ([local-copy](./media/13772-12.pdf))
- https://www.cisco.com/c/en/us/support/docs/ip/network-address-translation-nat/13773-2.html (ip nat outside) ([local-copy](./media/13773-2.pdf))
<!-- order switch inside/outside between the 2 docs -->

### Cisco NAT classification

- ip nat inside source	
    - Translates the source of IP packets that are traveling inside to outside. [case NI SRC] (SNAT)
    - Translates the destination of the IP packets that are traveling outside to inside.  [case NI DST] (DNAT)

- ip nat outside source	
    - Translates the source of the IP packets that are traveling outside to inside.  [case NO SRC] (SNAT)
    - Translates the destination of the IP packets that are traveling inside to outside. [case NO DST] (DNAT)

<!-- fixed: https://github.com/scoulomb/home-assistant/commit/ef7ba4bd7ebdae1af27a0ab66b21bb4e4ff34650#commitcomment-125601669 -->
Note
- [SNAT@home (standard)](#snat-at-home): When we do standard S(ource) NAT we configure [case NI SRC], but reverse traffic is actually doing  [case NI DST]
    - which is the case  [Configuration du NAT dynamique avec surcharge (sans pool) (many to one)](#configuration-du-nat-dynamique-avec-surcharge-sans-pool-many-to-one)
- [DNAT@home (standard)](#dnat-at-home): When we do standard D(estination) NAT we configure [case NI DST], but reverse traffic is actually doing  [case NI SRC]
    - which is the case [Use `static` D(estination) NAT](#use-static-destination-nat).

So equivalent `@home usage` is always using `ip nat inside source`


### Thus DNAT commands

DNAT example is this doc https://www.cisco.com/c/en/us/support/docs/ip/network-address-translation-nat/13772-12.html#topic12?

`1. Allow Internal Users to Access the Internet` => SNAT
`3. Redirect TCP Traffic to Another TCP Port or Address` -> Similar to DNAT but just port change


````
ip nat inside source static tcp 172.16.10.8 8080 172.16.10.8 80
````
And quoting the doc

````
Note: The configuration description for the static NAT command indicates any packet received in the inside interface with a source address of 172.16.10.8:8080 is translated to 172.16.10.8:80. This also implies that any packet received on the outside interface with a destination address of 172.16.10.8:80 has the destination translated to 172.16.10.8:8080.
````

Thus we deduce DNAT command

````
ip nat inside source static tcp private_ip private_port (eg .8080) public_ip public_port (eg. 80)
````
`
This is confirmed by https://networklessons.com/cisco/ccie-routing-switching/ip-nat-inside-source-vs-ip-nat-outside-source

We also `ip nat inside destination` (from https://feryjunaedi.files.wordpress.com/2008/02/nat-command.pdf p10 [/also in media ](./media/nat-command.pdf))

````
ip nat inside destination list {access-list-number | name} pool name [redundancy redundancy-id mapping-id map-id] `
````
I consider it is sugar synthax to `ip nat inside source`.


### When do we use `ip nat outside source`?	

Less frequent usage.
We change the original source IP of incoming packet. Nothing to do with SNAT [@home](#snat-at-home)


## See also F5 SNAT:


### F5 NATS and SNATs

From: https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-11-6-0/7.html
Forked [here](./media/tmos-routing-administration-11-6-0/AskF5%20_%20Manual%20Chapter_%20NATS%20and%20SNATs.html).

### Section `About NATs`

- Without NAT (use **standard (not fw)** virtual server) => This is a kind of  [case NI DST](#cisco-nat-classification) DNAT <=> [DNAT@home](#dnat-at-home) (inbound from F5 perspective)
  - More details at https://github.com/scoulomb/http-headers/blob/main/README.md#dnat-discussion <!-- link with private PPT / @PrezNewGen/note on F5 vs type OK with current understanding (ESB OK, MQADDS can change but no impact here) 15nov24 - optional to complete OK CCL STOP -->
- With a NAT (no virtual server involved here)
  - NAT for inbound connection    => This is  [case NI DST](#cisco-nat-classification) DNAT <=> [DNAT@home](#dnat-at-home) - Not similar to SNAT [Inbound](#inbound-connection), but similar to a simple virtual server (with [Secured SNAT or not](#inbound-connection))
  - NAT for outbound connection   => This is  [case NI SRC](#cisco-nat-classification) SNAT <=> [SNAT@home](#snat-at-home) - Similar to SNAT with [server initiated outbound connection](#snats-for-server-initiated-outbound-connections)

So ip NAT inside only
Note we can not translate the port: see https://clouddocs.f5.com/cli/tmsh-reference/v15/modules/ltm/ltm_nat.html


From: https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-11-6-0/7.html

### Section `About S(ecure)NATs`

> A secure network address translation (SNAT) is a BIG-IP Local Traffic Manager feature that translates the source IP address within a connection to a BIG-IP system IP address that you define. 
> The destination node then uses that new source address as its destination address when responding to the request.

> For inbound connections, that is, connections initiated by a client node, SNATs ensure that server nodes always send responses back through the BIG-IP system, 
> when the server’s default route would not normally do so. 
> Because a SNAT causes the server to send the response back through the BIG-IP system,
> the client sees that the response came from the address to which the client sent the request, and consequently accepts the response.

> For outbound connections, that is, connections initiated by a server node, SNATs ensure that the internal IP address of the server node remains hidden to an external host when the server initiates a connection to that host.


#### --- **Inbound connection**

> In the most common client-server network configuration, 
the Local Traffic Manager standard address translation mechanism ensures that server responses return to the client through the BIG-IP system, 
thereby reversing the original destination IP address translation. This typical network configuration is as follows:

    The server nodes are on the same subnet as the BIG-IP system.
    The client nodes are on a different subnet from the server nodes.
    The BIG-IP system is the default gateway for the server subnet. 

> However, there are atypical network configurations in which the standard BIG-IP system address translation sequence by itself does not ensure that server responses use the required return path.

Examples: `When the default gateway of the server node is not the BIG-IP system`

> For various reasons, the server node’s default route cannot always be defined to be a route back through the BIG-IP system. 
Again, this can cause problems such as the client rejecting the response because the source of the response does not match the destination of the request. 
The solution is to create a SNAT. 
> When Local Traffic Manager then translates the client node’s source IP address in the request to the SNAT address, 
this causes the server node to use that SNAT address as its destination address when sending the response. 
This, in turn, forces the response to return to the client node through the BIG-IP system rather than through the server node’s default gateway.

See diagram in page!

**This is not same SNAT as @home.**. It is SNAT between F5 and application (gateway).

It is  [case NO SRC](#ip-nat-outside). And reverse traffic doing [case NO DST](#cisco-nat-classification).
It shows an example where we would use [`ip nat outside source`](#when-do-we-use-ip-nat-outside-source).

This is convenient when F5 are in different network than server (ex. POP/Azure) to ensure reverse traffic come back to F5 (usually SNAT pool attached to vs, see below). 

Any standard virtual (not fwd, but both are possible) server is similar to  [DNAT](#section-about-nats) (client to F5 server). Here we can add **S(ource)NAT between F5 client and gateway/server/esb etc...** for return traffic.


Example where default gateway on the route does not require source ip packet change as here: https://github.com/scoulomb/misc-notes/blob/master/NAS-setup/Wake-On-LAN.md#android-wow


NAT table is (see [SNAT@home](#snat-at-home) or [DNAT@home](to compare))

| Input (WAN**)                        | Output (LAN**)                                   |
|--------------------------------------|--------------------------------------------------|
| client source IP, source NAT Port*   | Gateway (==targetted app) source IP, source Port |


* Dynamic port (which they try to preserve, from https://my.f5.com/manage/s/article/K7820)
** Reverse if [pellicular case for outbound](#pellicular-case-for-outbound). And in that case it is SNAT@home equivalent.

#### --- **SNATs for server-initiated (outbound) connections**

> When an internal server initiates a connection to an external host, a SNAT can translate the private, source IP addresses of one or more servers within the outgoing connection to a single, publicly-routable address. The external destination host can then use this public address as a destination address when sending the response. In this way, the private class IP addresses of the internal nodes remain hidden from the external host.
> More specifically, a SNAT for an outgoing connection works in the following way:

> 1. Local Traffic Manager receives a packet from an original IP address (that is, an internal server with a private IP address) and checks to see if that source address is defined in a SNAT.
> 2. If the original IP address is defined in a SNAT, Local Traffic Manager changes that source IP address to the translation address defined in the SNAT.
> 3. Local Traffic Manager then sends the packet, with the SNAT translation address as the source address, to the destination host.

Here they mention use-case of DNS request: From https://support.f5.com/csp/article/K7820

This is S(ource) NAT [case NI SRC](#cisco-nat-classification), but reverse traffic is actually doing  [case NI DST] 
<=>  [SNAT@home (standard)](#snat-at-home)


**Warning**: SNAT in F5 means "secure" (`S` is confusing can mean Source, Static and Secure....)

#### --- **Types of S(ecured)NATs**

The 3 types of translation adress we can use are
- a specific translation IP address,
- SNAT pool
- SNAT automap pool
Note we also have LSN for Large Scale Nat pool 

S(ecured)NAT objects we have 

- Standard SNAT object: (for [**Inbound connection**](#inbound-connection) and [**outbound connection**](#snats-for-server-initiated-outbound-connections) (see https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-11-6-0/7.html/ Creating a SNAT) with
  - specific translation IP ddress (one to one)
  - Automap SNAT (pool): many to many (use self ip adress: https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/big-ip-tmos-routing-administration-14-0-0/06.html)
  - SNAT pools: many to many (https://support.f5.com/csp/article/K47945399)
  - ==> referend in doc https://clouddocs.f5.com/cli/tmsh-reference/v15/modules/ltm/ltm_nat.html as `transation` | `automap` | `snatpool`. 
- SNAT pool assigned to virtual server (standard or forwarding IP) (only for [**Inbound connection**](#inbound-connection), but can reverse the F5, and use it to target provider (see [pellicular case for outbound](#pellicular-case-for-outbound)), so connectity is outbound (F5 do socket establisment to service provider) but it is inbound from F5 perspective) (see https://techdocs.f5.com/kb/en-us/products/big-ip_ltm/manuals/product/tmos-routing-administration-11-6-0/7.html / Creating a SNAT pool). 
    - We can only have SNAT pool, automap or LSN
    - See here https://clouddocs.f5.com/cli/tmsh-reference/v15/modules/ltm/ltm_virtual.html: `source-address-translation` property (replacing `snat`, `snatpool`).
    - To not confuse with `source` which specifies an IP address or network from which the virtual server will accept traffic.
- intelligent SNAT (irule) (only for [**Inbound connection**](#inbound-connection) if iRule attached to virtual server): https://serverfault.com/questions/1019723/can-we-have-multiple-snat-pools-configured-under-a-single-vip
    - Should be able to reuse any kind of translation address


### Virtual server + NAT + S(ecured) NATs 

We consider [**Inbound connection**](#inbound-connection) only

Multiple Source listener we have are
- [NATs (Origin address)](#section-about-nats)  - apply i/o (inbound and outbound)
- [SNATs (Origin)](#types-of-securednats) - Standard SNAT object - apply i/o
- Virtual server - Looks like [DNAT](#section-about-nats) + [S(ecured) Source NAT](#types-of-securednats) - apply i 
    - SNAT pool assinged to virtual server
    - intelligent SNAT (irule)

Precedence rule applies see https://my.f5.com/manage/s/article/K9038 (saved [here](./media/the))

Note that one
> NAT and virtual server (without a SNAT pool)
> If a request originating from the NAT's origin IP address also matches a virtual server without a SNAT pool, the virtual server will process the connection and apply the NAT translation address to the outgoing packet.

-> meaning reply is considered as [server initiated outbound connection](#snats-for-server-initiated-outbound-connections).


Multiple Source listener and Destination listener we have are
- virtual servers (many)

Precedence rule applies see https://my.f5.com/manage/s/article/K9038 (saved [here](./media/The%20order%20of%20precedence%20for%20local%20traffic%20object%20listeners.pdf))


I completed algo from https://support.f5.com/csp/article/K7820 with NAT
Forked [here](media/f5-k7820/f5-k7820.html).


Note SNAT aobject level avoids to define `Source Address Translation property` in each virtual server.

### Pellicular case for outbound 

We can use virtual server for outbound connection (SNAT pool or intelligent SNAT rule assigned to virtual server) to perform SNAT when sending traffic to external provider.
Meaning internal client is doing socket establishment to F5, F5 sends traffic to external provider.
So we are inbound from F5 persepcive but processed traffic is outbound. 
Note we can use 

- Standard virtual server (explicit SNAT)
- but also Using forwarding IP virtual server: https://support.f5.com/csp/article/K7595 (transparent SNAT)

See https://support.f5.com/csp/article/K93100324#link_07_01

Same mechanism used as in **SNAT between F5 and gateway/server/esb etc...** in [case](#inbound-connection) "`--- **Inbound connection**`"

But here we are equivalent SNAT [`@home usage`](#cisco-nat-classification) (ip nat inside case as using virtual server the other way around/reversed)

Note that
- a standard virtual server will still do a [kind of DNAT](#Section-About-NATs) (But here not same as [DNAT](#section-about-nats) [`@home usage`] (#cisco-nat-classification) as using virtual server the other way around/reversed)
- But a forwarding IP will not (https://my.f5.com/manage/s/article/K7595)

Reason why when targeting
- std vs: we target vs vip
- fw vs: we target remote ip directly

Quoting https://my.f5.com/manage/s/article/K7595

> An IP forwarding virtual server accepts traffic that matches the virtual server address and forwards it to the destination IP address that is specified in the request rather than load balancing the traffic to a pool.
> Address translation* is disabled when you create an IP forwarding virtual server, leaving the destination address in the packet unchanged. When creating an IP forwarding virtual server, as with all virtual servers, you can create either a host IP forwarding virtual server, which forwards traffic for a single host address, or a network IP forwarding virtual server, which forwards traffic for a subnet.

* It refers to destination IP unchanged 

<!-- NAT box is opening a new TCP connection (p483) it even modifies the packet,
Router does not go to TCP layer -->

<!-- p472
Un réseau correspond a un bloc contigu d’espace d’adressage IP.
C'est ce que on appelle un préfixe,
Les adresses IP sont écrites en notation décimale pointée
Dans cette forme un des 4 octets est représenté par un nombre décimal compris entre 0 et 255.
Dans l'exemple, l'adresse hexadécimale sur 32 bits 80D00297 equivaut  a 128.208.2.15 en notation décimale pointée.
On écrit les préfixed en indiquant l'adress IP la plus basse dans le bloc et la taille du bloc.
Cette taille est déterminde par le nombre de bit dans la partie réseau ;
les bits restants dans la partie hote sont variables
Autrement dit, la taille doit etre une puissance de 2.
Par convention, elle est notée a la suite de l'adresse IP du préfixe par une barre oblique (slash)
suivie par la bongueur en bits de la partie reseay
Dans notre exemple, si le préfixe content 2^8 adressse, ce qui laisse 24 bits pour la partie réseau, 
on |’écrit 128.208.0.0/24.
Comme on ne peut pas deduire,la longueur du préfixe uniquement a partir de Tadresse IP, 
les protocoles de routage doivent rarismettre les préfixes aux routeurs. 
Les préfixes sont parfois decrits simplement par leur longueur, comme « /16 » (slash 16).
La longueur du prefixe correpond a un Masque binaire de 1 dans la partie réseau. 
Ecrit sous cette forme.il se nommede sous-réseau.
On peut l’associer avec l’adresse IP au moven d'une operation booleane AND, ou ET logique, pour obtenir la partie reseau seulement
Dans notre exemple, le masque de sous-réseau est 255.255.255.0. La figure 5.48 montre
un prefixe et un masque de sous-réseau. 

p474
routeur reqarde adresse, applique chaque masque de sous reseau (donc garde la partie reseau)
si un reseau match sait ou router !

https://github.com/scoulomb/misc-notes/blob/master/NAS-setup/Wake-On-LAN.md#wol---how-does-it-work
Bottom of page 

We see 192.168.1.255 as broadcast IP
Which means than network mask is 255.255.255.0

And it matches setup we can see in DENON
IP:192.168.1.33
Subnet mask:255.255.255.0
Gateway: 192.168.1.1 => addresse la plus basse, coherent p499 *in bold*
DNS:192.168.1.1 => then fwd to SFR DNS (details in mydns)

vs usually inbound but could be outbound, think compatible stop here
-->

See links to private_script/blob/main/Links-mig-auto-cloud/README.md#topics <!-- clear ok ! -->


**We alyways consider forwarding IP virtual server (https://github.com/scoulomb/http-headers/blob/main/README.md#f5-types-of-virtual-server), but a forwarding layer 2 virtual server can also have SNAT: https://my.f5.com/manage/s/article/K10371011**.
We say `forwarding IP virtual server` (cf hyperlink above)  or `IP forwarding virtual` (cf. quote in this doc)

## SNAT and Azure

Here `S` is for Source.
We can assume an AZ LB is also doing a kind of DNAT. As for [F5](#section-about-nats) 

- Azure SNAT overview:  https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-outbound-connections
    - > The following methods are Azure's most commonly used methods to enable outbound connectivity:

    | # | Method | Type of port allocation | Production-grade? | Rating |
    | ------------ | ------------ | ------ | ------------ | ------------ |
    | 1 | Use the frontend IP address(es) of a load balancer for outbound via outbound rules | Static, explicit | Yes, but not at scale | OK | 
    | 2 | Associate a NAT gateway to the subnet | Dynamic, explicit | Yes | Best | 
    | 3 | Assign a public IP to the virtual machine | Static, explicit | Yes | OK | 
    | 4 | [Default outbound access](../virtual-network/ip-services/default-outbound-access.md) use | Implicit | No | Worst |
    
    - NAT table is similar to [SNAT @home](#snat-at-home)

        | Input (LAN)                                  | Output (WAN)                     |
        |----------------------------------------------|----------------------------------|
        | AZ internal IP, original source Port (OS)    | Source WAN IP, Source Port (NAT)*| 


    - Port exhaustion: https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-outbound-connections 
        - > Every **connection** to the **same destination IP and destination port will use a SNAT port**. This connection maintains a distinct traffic flow from the backend instance or client to a server. This process gives the server a distinct port on which to address traffic. Without this process, the client machine is unaware of which flow a packet is part of.
        - > Without different destination ports for the return traffic (the SNAT port used to establish the connection), the client will have no way to separate one query result from another
        - > Outbound connections can burst. A backend instance can be allocated insufficient ports. Use connection reuse functionality within your application. Without connection reuse, the risk of SNAT port exhaustion is increased.
        - > Rephrased https://azure.microsoft.com/en-us/blog/dive-deep-into-nat-gateway-s-snat-port-behavior/. Store locally [here](./media/Dive%20deep%20into%20NAT%20gateway’s%20SNAT%20port%20behavior%20|%20Azure%20Blog%20|%20Microsoft%20Azure.pdf).
            - > With each new connection to the same destination IP and port, **a new source port is used.**
            - > A new source port is necessary so that each connection can be distinguished from one another
        - ==> SNAT port consumed for each (connection, destination IP, destination Port) 
            - if we have a new connection targetting same destination ip and port, we will require a new SNAT port
            - If we need a new source Port (NAT) targeting same destination (ip and port) for a new connection as a freshly released SNAT port,  Azure puts in place a reuse cooldown timer to reuse this port  after a given time (see https://learn.microsoft.com/en-us/azure/nat-gateway/nat-gateway-resource#port-reuse-timers)
            - Reason why we should use a much as possible connection reusage with persistent connection (https://en.wikipedia.org/wiki/HTTP_persistent_connection) 
            - When all SNAT ports are in use, NAT gateway can reuse a SNAT port to connect outbound so long as the port actively in use goes to a different destination endpoint. -> Endpoint is (ip, port)
            - [Current understand OK] Actually more precsion. "when all SNAT port in use": https://learn.microsoft.com/en-us/azure/load-balancer/load-balancer-outbound-connections#port-exhaustion
                - > For TCP connections, the load balancer uses a single SNAT port for every destination IP and port. This multiuse enables multiple connections to the same destination IP with the same SNAT port. This multiuse is limited if the connection isn't to different destination ports. {meaning we can reuse a SNAT port on same machine/ip if targetted port is different, also possible on another and with same port or not }
                - > For UDP connections, the load balancer uses a port-restricted cone NAT algorithm, which consumes one SNAT port per destination IP whatever the destination port. {meaning we can not reuse a SNAT port on same ip even if targetted port is different, also possible on another and with same port or not }
                - > A port is reused for an unlimited number of connections. The port is only reused if the destination IP or port is different.
                <!-- ok clear -->
                - More details on Full Cone NAT
                    - https://www.lri.fr/~fmartignon/documenti/reseauxavances/NAT-Netkit.pdf. Stored [here](./media/NAT-Netkit.pdf).
                    - I assume TCP is symetric NAT (so only answers)
                    - Observe that SNAT@home return taffic is DNAT@home abnd vice-versa: https://github.com/scoulomb/docker-under-the-hood/blob/main/NAT-deep-dive-appendix/README.md#cisco-nat-classification
                    - So here we talk SNAT and DNAT and restriction, not different facade IP for each destination IP when symetric  


- Why 64,512 port per IP? From https://cloud.google.com/nat/docs/ports-and-addresses
    > Each NAT IP address on a Cloud NAT gateway (both Public NAT and Private NAT) offers 64,512 TCP source ports and 64,512 UDP source ports. TCP and UDP each support 65,536 ports per IP address, but Cloud NAT doesn't use the first 1,024 well-known (privileged) ports.

- Azure NAT GW has up to 16 pub adress so 1,032,192 SNAT port

- This article show table: https://azure.microsoft.com/en-us/blog/dive-deep-into-nat-gateway-s-snat-port-behavior/ but our represntation are more accurate, see https://azure.microsoft.com/en-us/blog/dive-deep-into-nat-gateway-s-snat-port-behavior/

- Load balancer SNAT: Load balancer can do SNAT but better to use SNAT gateway
    - https://learn.microsoft.com/en-us/azure/virtual-network/nat-gateway/tutorial-nat-gateway-load-balancer-public-portal
    - https://learn.microsoft.com/en-us/azure/load-balancer/outbound-rules (similar to forwarding IP vs)

- SNAT gateway
    - https://learn.microsoft.com/en-us/azure/virtual-network/nat-gateway/nat-gateway-resource?source=recommendations#source-network-address-translation (SNAT port reuse wrong, https://github.com/MicrosoftDocs/azure-docs/pull/103407, consider OK)
    - https://learn.microsoft.com/en-us/azure/virtual-network/nat-gateway/quickstart-create-nat-gateway-portal

- Voir private script --> aks-istio-and-azure-nat.md
<!-- above SNAT F5-GW outbound POP->AZ, here outbound AZ -> External world, stop here, DNAT stop -->
<!-- ok -->
<!-- reconcluded 30.12.22 + 4.01.23 with Azure -->

## NAT @home

See [classisication](#cisco-nat-classification).

### SNAT at home

Assume Laptop/Device private IP is `192.168.1.32` 
Making HTTP Call to `External IP:External Port` (`google.fr:443`)

Where WAN IP/outbound facade/SNAT/WAN IP is `109.29.148.109`.

TCP connection is 

`[Laptop IP, original source Port (OS randomly chosen)] -> [External IP, external Port]`

But we have NAT in between 

`[Laptop IP, original source Port (OS randomly chosen)] -> [SFR: WAN IP, source Port (NAT)] --Internet--> [External IP, external Port]`

Thus NAT table 

| Input (LAN)                                  | Output (WAN)                     |
|----------------------------------------------|----------------------------------|
| Laptop source IP, original source Port (OS)  | Source WAN IP, Source Port (NAT)*| 

* Dynamic port

To determine which devices originated the traffic

If we have double (S)NAT we apply this 2 times (we have box router WAN IP + google Home WAN IP). 
Double NAT is acheievd when we have 2 routers.

`[Laptop IP, original source Port (OS randomly chosen)] --Google Nest LAN--> [Google Nest: WAN IP, source Port (NAT1)] --SFR LAN--> [SFR: WAN IP, source Port (NAT2)]  --Internet--> [External IP, external Port]`

When we use several ports with one IP it is called many to one NAT: https://github.com/scoulomb/docker-under-the-hood/tree/main/NAT-deep-dive-appendix#configuration-du-nat-dynamique-avec-surcharge-sans-pool-many-to-one

This is the the case at home

Best is to use many IP with port re-usage.


### DNAT at home 

`[Client Source IP, Source Port] --Internet--> [SFR WAN IP, DNAT Port] --SFR LAN--> [Laptop/Device IP, Laptop/Device Port]`

Note the client is most likely exposing himself a Source NATTED IP as done [above](#snat-at-home).

So we have a NAT table


| Input (WAN)                                             | Output (LAN)                             |
|---------------------------------------------------------|------------------------------------------|
| client source IP (not in config), Destination NAT Port  | Laptop destination IP, destination Port  |

Port can be a range

If we have double NAT we apply this several times (port managment in google app)

````
[Client Source IP, Source Port] --Internet--> [SFR: WAN IP, WAN/DNAT Port] --SFR LAN-->  [Google Nest: WAN IP, WAN/NAT Port] --Google Nest LAN-->  [Laptop/Device IP, Laptop/Device Port]
````

Note `Google Nest` is a router, `SFR box` is modem+router. 

We can have device in SFR LAN and Google Nest LAN at same time.

In router it is confugred in http://192.168.1.1/network/nat

In NAT table we can have the protocol (TCP,UDP, both)

### HOME AUTOMATION

**See [S/DNAT and Home Automation](https://github.com/scoulomb/home-assistant#note-on-network)**


## NAT @corpo

### Inboubd con 

see private_script 

<!-- [](../../private_script/Links-mig-auto-cloud/natting/README.md#migration-and-snatdnat)/  https://github.com/scoulomb/docker-under-the-hood/tree/main/NAT-deep-dive-appendix / Inbound IP -->

### Outbound con 

see private_script 

<!-- [](../../private_script/Links-mig-auto-cloud/natting/README.md#migration-and-snatdnat) /  https://github.com/scoulomb/docker-under-the-hood/tree/main/NAT-deep-dive-appendix / outbound case -->

S(ource)NAT is usually done on LB (standard virtual server or forwarding IP virtual server/transparent SNAT, see [pellicular case for outbound](#pellicular-case-for-outbound)) or via Firewall. 
<-- ERD/POP -->

### We can have SNAT pool exhaustion.  
<!-- /my conflu space/Interesting+Problems --> 

See https://my.f5.com/manage/s/article/K7820
For instance [between F5 and gateway](#inbound-connection) 
 
Pool is exhausted when for all IP in pool, all source port are used (same as [Azure](#snat-and-azure)
To avoid pool exhaustion we can
- Increase the pool of IP: but it impacts customer as source IP would change, so customer has to open more firewall 
- Or we avoid to comsume a new SNAT port usage by maximizing connection reuse. To achieve this we have to 
    <!-- (esb view con) --> 
    - Reducing Connection inactivity timeout
    - Not close on reply
    - Ensure we do `http 1.1 and persistent mode (https://en.wikipedia.org/wiki/HTTP_persistent_connection)
<!-- we go for second option -->
<!-- doubt and yet very clear do not come bacl -->
<!-- it is concluded and full review with, brain seems overload but actually well done and clear
[](../../private_script/Links-mig-auto-cloud/natting/README.md#migration-and-snatdnat)
https://github.com/scoulomb/docker-under-the-hood/blob/main/NAT-deep-dive-appendix/README.md#nat-deep-dive
https://github.com/scoulomb/home-assistant/blob/main/README.md#note-on-network
 -->

 ## Other links

- Links-mig-auto-cloud/README.md#migration-and-snatdnat 
- https://github.com/scoulomb/home-assistant/blob/main/README.md#note-on-network

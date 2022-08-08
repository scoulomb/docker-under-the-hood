# SNAT in details


I also recommend to read [Tanenbaum, Reseau 5eme edition] chapitre 5, La couche reseau, section 5.6: Couche reseau dans l'Internet (p465)

## Quoting Tanenbaum

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



## Comment

### Prereq

Read https://github.com/scoulomb/misc-notes/blob/master/NAS-setup/Wake-On-LAN.md
And all section marked as 
`[From Tanenbaum, Reseau 5eme edition] chapitre 5, La couche reseau, section 5.6: Couche reseau dans l'Internet (p465)....`

### Source port

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
    # We have DNS query, ARP request and NAT table updated, then TLS (client hello) and OCSP (https://github.com/scoulomb/misc-notes/tree/master/tls)
    
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

Then here we explained how Ethernet frame is received: https://github.com/scoulomb/misc-notes/blob/master/NAS-setup/Wake-On-LAN.md#reminder-on-arp
>  Maintenant que le logiciel IP de l’hote 1 détient l'adresse Ethernet de l’hote 2, ....
Where is the IP is not in the LAN.
 
This source port can also be seen [Wake on LAN request](https://github.com/scoulomb/misc-notes/blob/master/NAS-setup/Wake-On-LAN.md#wol---how-does-it-work) as explained in that section.

Example given in this [link](https://github.com/scoulomb/misc-notes/blob/master/NAS-setup/media/wireshark-export-android-wol-192-168-1-255.txt).

<!--
p474
Division de prefixe IP (apply mask to know to which network to route)
p477
aggregation de prefixe IP: Route la plus specifique, ou dans celle du plus long prefixe correspondant ayant le moins d'adresse ip,
p504
Routage intradomaine OSPF
p510
Routage interdomaine BGP

private_script/tree/main/Links-mig-auto-cloud, for migration prefix and BGP, do not enter in details stop

-->
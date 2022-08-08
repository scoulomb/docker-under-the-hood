# Undertand Docker and linux namespaces

## Concepts

- Namespace: isolation layer 
- CGroup:
    - Limit/fairness we set on a resource/namespace
    - CGroup is considered as one of the 7 linux namespaces

See here more info on concept

- https://www.infoq.com/articles/build-a-container-golang/
- https://containers.goffinet.org/containers/081-namespaces_cgroups


## Docker and Linux namespaces

For our investigation we will use this compose file: https://github.com/open-denon-heos/remote-control/blob/main/PRD.docker-compose.yaml.

And do `docker-compose up -f PRD.docker-compose.yaml`.

This should trigger a `flask` and `apache` process. Those are visible via `ps`.
We had seen in it in this post: https://github.com/scoulomb/misc-notes/blob/master/lab-env/kubernetes-distribution.md

### Let's explore Network namespace

#### Root and ls command (Self) namespace

````
scoulomb@scoulomb-HP-Pavilion-TS-Sleekbook-14:~$ sudo ls -l /proc/1/ns
total 0
lrwxrwxrwx 1 root root 0 juil. 22 15:41 cgroup -> 'cgroup:[4026531835]'
lrwxrwxrwx 1 root root 0 juil. 22 15:48 ipc -> 'ipc:[4026531839]'
lrwxrwxrwx 1 root root 0 juil. 22 15:41 mnt -> 'mnt:[4026531840]'
lrwxrwxrwx 1 root root 0 juil. 22 15:48 net -> 'net:[4026532008]'
lrwxrwxrwx 1 root root 0 juil. 22 15:41 pid -> 'pid:[4026531836]'
lrwxrwxrwx 1 root root 0 juil. 22 15:48 pid_for_children -> 'pid:[4026531836]'
lrwxrwxrwx 1 root root 0 juil. 22 15:48 time -> 'time:[4026531834]'
lrwxrwxrwx 1 root root 0 juil. 22 15:48 time_for_children -> 'time:[4026531834]'
lrwxrwxrwx 1 root root 0 juil. 22 15:48 user -> 'user:[4026531837]'
lrwxrwxrwx 1 root root 0 juil. 22 15:48 uts -> 'uts:[4026531838]'
scoulomb@scoulomb-HP-Pavilion-TS-Sleekbook-14:~$ sudo ls -l /proc/self/ns
total 0
lrwxrwxrwx 1 root root 0 juil. 24 00:00 cgroup -> 'cgroup:[4026531835]'
lrwxrwxrwx 1 root root 0 juil. 24 00:00 ipc -> 'ipc:[4026531839]'
lrwxrwxrwx 1 root root 0 juil. 24 00:00 mnt -> 'mnt:[4026531840]'
lrwxrwxrwx 1 root root 0 juil. 24 00:00 net -> 'net:[4026532008]'
lrwxrwxrwx 1 root root 0 juil. 24 00:00 pid -> 'pid:[4026531836]'
lrwxrwxrwx 1 root root 0 juil. 24 00:00 pid_for_children -> 'pid:[4026531836]'
lrwxrwxrwx 1 root root 0 juil. 24 00:00 time -> 'time:[4026531834]'
lrwxrwxrwx 1 root root 0 juil. 24 00:00 time_for_children -> 'time:[4026531834]'
lrwxrwxrwx 1 root root 0 juil. 24 00:00 user -> 'user:[4026531837]'
lrwxrwxrwx 1 root root 0 juil. 24 00:00 uts -> 'uts:[4026531838]'
scoulomb@scoulomb-HP-Pavilion-TS-Sleekbook-14:~$ sudo ls -l /proc/1/ns | awk '{print $11}' > 1.ns
scoulomb@scoulomb-HP-Pavilion-TS-Sleekbook-14:~$ sudo ls -l /proc/self/ns | awk '{print $11}' > self.ns
scoulomb@scoulomb-HP-Pavilion-TS-Sleekbook-14:~$ diff self.ns 1.ns
scoulomb@scoulomb-HP-Pavilion-TS-Sleekbook-14:~$ 
````

They both share same namespace.

<!-- those command were run after, but laptop in standby some same namespace, could be interesting to check full shut down impact -->

#### Flask (host network)

````
scoulomb@scoulomb-HP-Pavilion-TS-Sleekbook-14:~$ ps -aux | grep -i flask
root       11942  0.0  0.3  32024 27056 ?        Ss   15:53   0:00 /usr/local/bin/python /usr/local/bin/flask run --port 5000 --host 0.0.0.0
scoulomb   12728  0.0  0.0   9264  2368 pts/1    S+   16:13   0:00 grep --color=auto -i flask
````

We can see PID is `11942`, we can see all namespace attached to this PID

````
scoulomb@scoulomb-HP-Pavilion-TS-Sleekbook-14:~$ sudo ls -l /proc/11942/ns
total 0
lrwxrwxrwx 1 root root 0 juil. 22 15:58 cgroup -> 'cgroup:[4026532334]'
lrwxrwxrwx 1 root root 0 juil. 22 15:58 ipc -> 'ipc:[4026532332]'
lrwxrwxrwx 1 root root 0 juil. 22 15:58 mnt -> 'mnt:[4026532330]'
lrwxrwxrwx 1 root root 0 juil. 22 15:58 net -> 'net:[4026532008]'
lrwxrwxrwx 1 root root 0 juil. 22 15:58 pid -> 'pid:[4026532333]'
lrwxrwxrwx 1 root root 0 juil. 22 15:58 pid_for_children -> 'pid:[4026532333]'
lrwxrwxrwx 1 root root 0 juil. 22 15:58 time -> 'time:[4026531834]'
lrwxrwxrwx 1 root root 0 juil. 22 15:58 time_for_children -> 'time:[4026531834]'
lrwxrwxrwx 1 root root 0 juil. 22 15:58 user -> 'user:[4026531837]'
lrwxrwxrwx 1 root root 0 juil. 22 15:58 uts -> 'uts:[4026532331]'
`````

Some namespaces are different from PID 1 (cgroup, ipc)

```` 
scoulomb@scoulomb-HP-Pavilion-TS-Sleekbook-14:~$ sudo ls -l /proc/1/ns
total 0
lrwxrwxrwx 1 root root 0 juil. 22 15:41 cgroup -> 'cgroup:[4026531835]'
lrwxrwxrwx 1 root root 0 juil. 22 15:48 ipc -> 'ipc:[4026531839]'
lrwxrwxrwx 1 root root 0 juil. 22 15:41 mnt -> 'mnt:[4026531840]'
lrwxrwxrwx 1 root root 0 juil. 22 15:48 net -> 'net:[4026532008]'
lrwxrwxrwx 1 root root 0 juil. 22 15:41 pid -> 'pid:[4026531836]'
lrwxrwxrwx 1 root root 0 juil. 22 15:48 pid_for_children -> 'pid:[4026531836]'
lrwxrwxrwx 1 root root 0 juil. 22 15:48 time -> 'time:[4026531834]'
lrwxrwxrwx 1 root root 0 juil. 22 15:48 time_for_children -> 'time:[4026531834]'
lrwxrwxrwx 1 root root 0 juil. 22 15:48 user -> 'user:[4026531837]'
lrwxrwxrwx 1 root root 0 juil. 22 15:48 uts -> 'uts:[4026531838]'
````

But we can see `net` namespace is the same : `'net:[4026532008]'`.

We can see here other process using same network namespace

````
scoulomb@scoulomb-HP-Pavilion-TS-Sleekbook-14:~$ ps -aux | grep flask
root       11942  0.0  0.3  32024 27056 ?        Ss   15:53   0:00 /usr/local/bin/python /usr/local/bin/flask run --port 5000 --host 0.0.0.0
scoulomb   12919  0.0  0.0   9264  2368 pts/1    S+   16:21   0:00 grep --color=auto flask
scoulomb@scoulomb-HP-Pavilion-TS-Sleekbook-14:~$ sudo ls -l /proc/*/ns | grep -P '4026532008|/proc/' | grep -A 5 11942
/proc/11942/ns:
lrwxrwxrwx 1 root root 0 juil. 22 15:58 net -> net:[4026532008]
/proc/119/ns:
lrwxrwxrwx 1 root root 0 juil. 22 16:01 net -> net:[4026532008]
/proc/11/ns:
lrwxrwxrwx 1 root root 0 juil. 22 16:01 net -> net:[4026532008]
````

This is because this container is using `host` network.

#### Apache (custom bridge network created by compose)

if repeat same operation 

````
scoulomb@scoulomb-HP-Pavilion-TS-Sleekbook-14:~$ ps -aux | grep -i apache
root       12078  0.0  0.0   2888  1760 ?        Ss   15:54   0:00 /bin/sh /usr/sbin/apachectl start
root       12145  0.0  0.0   7108  5648 ?        S    15:54   0:00 /usr/sbin/apache2 -DFOREGROUND -k start
www-data   12146  0.0  0.0 1998224 4192 ?        Sl   15:54   0:00 /usr/sbin/apache2 -DFOREGROUND -k start
www-data   12147  0.0  0.0 1998224 4192 ?        Sl   15:54   0:00 /usr/sbin/apache2 -DFOREGROUND -k start
scoulomb   12782  0.0  0.0   9264  2288 pts/1    S+   16:16   0:00 grep --color=auto -i apache
scoulomb@scoulomb-HP-Pavilion-TS-Sleekbook-14:~$ sudo ls -l /proc/12146/ns
total 0
lrwxrwxrwx 1 root root 0 juil. 22 15:56 cgroup -> 'cgroup:[4026532495]'
lrwxrwxrwx 1 root root 0 juil. 22 15:56 ipc -> 'ipc:[4026532338]'
lrwxrwxrwx 1 root root 0 juil. 22 15:56 mnt -> 'mnt:[4026532336]'
lrwxrwxrwx 1 root root 0 juil. 22 15:56 net -> 'net:[4026532341]'
lrwxrwxrwx 1 root root 0 juil. 22 15:56 pid -> 'pid:[4026532339]'
lrwxrwxrwx 1 root root 0 juil. 22 15:56 pid_for_children -> 'pid:[4026532339]'
lrwxrwxrwx 1 root root 0 juil. 22 15:56 time -> 'time:[4026531834]'
lrwxrwxrwx 1 root root 0 juil. 22 15:56 time_for_children -> 'time:[4026531834]'
lrwxrwxrwx 1 root root 0 juil. 22 15:56 user -> 'user:[4026531837]'
lrwxrwxrwx 1 root root 0 juil. 22 15:56 uts -> 'uts:[4026532337]'
````

We can see this time that network namespace is different, it is different from the host:
`'net:[4026532341]'`


### Deep dive on Docker network 

We will add a third container 


````
scoulomb@scoulomb-HP-Pavilion-TS-Sleekbook-14:~/heos/open-denon-heos/remote-control$ cat PRD.docker-compose.yaml
version: "3.6"
services:
  server:
    image: scoulomb/heos-api-server:1.0.0
    environment:
      - CONF_PLAYER_NAME=Denon AVR-X2700H
      - CONF_USER=fake@gmail.com
      - CONF_PW=do-not-use-qwerty-as-your-password
    network_mode: host
  remote-control:
    image: scoulomb/heos-remote-control:1.0.0
    ports:
      - 8000:80
  python:
    image: python
    command: sleep 6000
    ports:
      - 8001:80
````

This will create 3 containers:

- Flask: host network
- Apache: custom network. It is the Docker compose `custom bridge` created by default by Compose which is different from Docker `default` bridge. We explained this in details here:  https://github.com/open-denon-heos/remote-control#default-setup-explanation-in-docker

    > - By default Compose sets up a single network for your app. Each container for a service joins the default network and is both reachable by other containers on that network, and discoverable by them at a hostname identical to the container name.
    > - Compose default behavior override Docker default behavior (`default` Bridge).

- Python attached to same network as Apache.


#### Docker to docker communication in same Docker network

##### Observations


Then looking at Apache and Python namespaces:

````
root@scoulomb-HP-Pavilion-TS-Sleekbook-14:~# ps -aux | grep sleep
root        2008  0.0  0.3  33980 24900 ?        S    15:41   0:00 ddclient - sleeping for 40 seconds
root       20392  0.1  0.0   4224   568 ?        Ss   18:26   0:00 sleep 6000
root       20615  0.0  0.0   9264  2376 pts/1    S+   18:26   0:00 grep --color=auto sleep
root@scoulomb-HP-Pavilion-TS-Sleekbook-14:~# ps -aux | grep apache
root       20427  0.0  0.0   2888   960 ?        Ss   18:26   0:00 /bin/sh /usr/sbin/apachectl start
root       20543  0.0  0.0   7108  5780 ?        S    18:26   0:00 /usr/sbin/apache2 -DFOREGROUND -k start
www-data   20548  0.0  0.0 1998224 4268 ?        Sl   18:26   0:00 /usr/sbin/apache2 -DFOREGROUND -k start
www-data   20549  0.0  0.0 1998224 4268 ?        Sl   18:26   0:00 /usr/sbin/apache2 -DFOREGROUND -k start
root       20622  0.0  0.0   9264  2320 pts/1    S+   18:26   0:00 grep --color=auto apache

root@scoulomb-HP-Pavilion-TS-Sleekbook-14:~# sudo ls -l /proc/20392/ns
total 0
lrwxrwxrwx 1 root root 0 juil. 22 18:27 cgroup -> 'cgroup:[4026534266]'
lrwxrwxrwx 1 root root 0 juil. 22 18:27 ipc -> 'ipc:[4026532495]'
lrwxrwxrwx 1 root root 0 juil. 22 18:27 mnt -> 'mnt:[4026532493]'
lrwxrwxrwx 1 root root 0 juil. 22 18:26 net -> 'net:[4026532592]'
lrwxrwxrwx 1 root root 0 juil. 22 18:27 pid -> 'pid:[4026532547]'
lrwxrwxrwx 1 root root 0 juil. 22 18:27 pid_for_children -> 'pid:[4026532547]'
lrwxrwxrwx 1 root root 0 juil. 22 18:27 time -> 'time:[4026531834]'
lrwxrwxrwx 1 root root 0 juil. 22 18:27 time_for_children -> 'time:[4026531834]'
lrwxrwxrwx 1 root root 0 juil. 22 18:27 user -> 'user:[4026531837]'
lrwxrwxrwx 1 root root 0 juil. 22 18:27 uts -> 'uts:[4026532494]'
root@scoulomb-HP-Pavilion-TS-Sleekbook-14:~# sudo ls -l /proc/20548/ns
total 0
lrwxrwxrwx 1 root root 0 juil. 22 18:27 cgroup -> 'cgroup:[4026534342]'
lrwxrwxrwx 1 root root 0 juil. 22 18:27 ipc -> 'ipc:[4026534269]'
lrwxrwxrwx 1 root root 0 juil. 22 18:27 mnt -> 'mnt:[4026534267]'
lrwxrwxrwx 1 root root 0 juil. 22 18:27 net -> 'net:[4026534272]'
lrwxrwxrwx 1 root root 0 juil. 22 18:27 pid -> 'pid:[4026534270]'
lrwxrwxrwx 1 root root 0 juil. 22 18:27 pid_for_children -> 'pid:[4026534270]'
lrwxrwxrwx 1 root root 0 juil. 22 18:27 time -> 'time:[4026531834]'
lrwxrwxrwx 1 root root 0 juil. 22 18:27 time_for_children -> 'time:[4026531834]'
lrwxrwxrwx 1 root root 0 juil. 22 18:27 user -> 'user:[4026531837]'
lrwxrwxrwx 1 root root 0 juil. 22 18:27 uts -> 'uts:[4026534268]'
````

We can see that network namespaces are different !

But each networks namespaces is attached to a veth: https://network-insight.net/2016/03/19/hands-on-docker-networking-and-namespaces/.
And Docker which have veth in same network, meaning they use same network bridge (can be `custom/user-defined bridge` including the one created by default by Compose) or `default bridge` (`docker0 bridge`) can communicate.

See picture and artcile here: https://argus-sec.com/docker-networking-behind-the-scenes/


![docker com](media/docker-com.png)

In schema/article they use `default bridge` (docker0), here for our demo we use `custom/user-defined bridge` created by default by Compose.

So Apache and Python container can communicate via bridge (using port 80, not the 8000 forwarded port)


````
scoulomb@scoulomb-HP-Pavilion-TS-Sleekbook-14:~/heos/open-denon-heos/remote-control$ docker-compose -f PRD.docker-compose.yaml exec python
scoulomb@scoulomb-HP-Pavilion-TS-Sleekbook-14:~/heos/open-denon-heos/remote-control$ docker-compose -f PRD.docker-compose.yaml exec python /bin/bash
root@32bdd3e24faa:/# curl remote-control:8000
curl: (7) Failed to connect to remote-control port 8000: Connection refused
root@32bdd3e24faa:/# curl remote-control:80
<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <meta name="generator" content="GitLab Pages" />
    <title>HEOS Remote Control</title>
    <link rel="stylesheet" href="style.css" />
    <script defer="defer" src="script.js"></script>
  </head>

  <body>
    <h1>HEOS Remote Control</h1>
    <noscript>
      <dialog open>
        <p>Javascript is required for this page to be functional.</p>
      </dialog>
    </noscript>
````


Can we communicate with `server` which exposes port 5000? (docker to docker where 2nd docker is in host network)

Not working as it is a host network

````
root@32bdd3e24faa:/# curl server:5000
curl: (6) Could not resolve host: server
````
Not working as it IP of localhost

````
root@32bdd3e24faa:/# curl 127.0.0.1:5000
curl: (7) Failed to connect to 127.0.0.1 port 5000: Connection refused
````

Solution is to use Docker host gateway which route to host.
See below [host network](#host)

````
root@32bdd3e24faa:/# curl 172.17.0.1:5000
<html>
  <head>
  </head>
  <body>
    <h1>Some sample commands</h1>
    <h2>Player</h2>
    <ul>
````

It has same IP as `docker0 gateway/default bridge/sudo docker inspect bridge` but is a different concept: https://megamorf.gitlab.io/2020/09/19/access-native-services-on-docker-host-via-host-docker-internal/ 
What is used in open denon heos UI.


##### Evidences 

Check Python and Apache container in same Docker network

````
root@scoulomb-HP-Pavilion-TS-Sleekbook-14:~# docker network ls | grep remote
5c12fb711107   remote-control_default   bridge    local
root@scoulomb-HP-Pavilion-TS-Sleekbook-14:~# docker inspect root@scoulomb-HP-Pavilion-TS-Sleekbook-14:~# docker network ls | grep remote
5c12fb711107   remote-control_default   bridge    local
root@scoulomb-HP-Pavilion-TS-Sleekbook-14:~# docker inspect 5c12fb711107
[
    {
        "Name": "remote-control_default",
        "Id": "5c12fb7111070ca64f77f4181679cb79b1d122f2763d21d58b984d2a46b5b307",
        "Created": "2022-06-05T18:00:26.971628861+02:00",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.20.0.0/16",
                    "Gateway": "172.20.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": true,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {
            "32bdd3e24faa25b718073f5397b8954ec9aba15dfe913120316edf8640672233": {
                "Name": "remote-control_python_1",
                "EndpointID": "0111feecc74c48dddbb232361a51c7891529a5116d00e98efc6bb5ec191e6518",
                "MacAddress": "02:42:ac:14:00:02",
                "IPv4Address": "172.20.0.2/16",
                "IPv6Address": ""
            },
            "bbf2fc3f3aa93b6c5d2c93cc8063626068be5cc9944e954de2d0d25856b57f80": {
                "Name": "remote-control_remote-control_1",
                "EndpointID": "cc6d19813468151751009077b12fe78634f71e4cab7f958934d56e072046e41f",
                "MacAddress": "02:42:ac:14:00:03",
                "IPv4Address": "172.20.0.3/16",
                "IPv6Address": ""
            }
        },
        "Options": {},
        "Labels": {
            "com.docker.compose.network": "default",
            "com.docker.compose.project": "remote-control",
            "com.docker.compose.version": "1.29.2"
        }
    }
]
[
    {
        "Name": "remote-control_default",
        "Id": "5c12fb7111070ca64f77f4181679cb79b1d122f2763d21d58b984d2a46b5b307",
        "Created": "2022-06-05T18:00:26.971628861+02:00",
        "Scope": "local",
        "Driver": "bridge",
        "EnableIPv6": false,
        "IPAM": {
            "Driver": "default",
            "Options": null,
            "Config": [
                {
                    "Subnet": "172.20.0.0/16",
                    "Gateway": "172.20.0.1"
                }
            ]
        },
        "Internal": false,
        "Attachable": true,
        "Ingress": false,
        "ConfigFrom": {
            "Network": ""
        },
        "ConfigOnly": false,
        "Containers": {
            "32bdd3e24faa25b718073f5397b8954ec9aba15dfe913120316edf8640672233": {
                "Name": "remote-control_python_1",
                "EndpointID": "0111feecc74c48dddbb232361a51c7891529a5116d00e98efc6bb5ec191e6518",
                "MacAddress": "02:42:ac:14:00:02",
                "IPv4Address": "172.20.0.2/16",
                "IPv6Address": ""
            },
            "bbf2fc3f3aa93b6c5d2c93cc8063626068be5cc9944e954de2d0d25856b57f80": {
                "Name": "remote-control_remote-control_1",
                "EndpointID": "cc6d19813468151751009077b12fe78634f71e4cab7f958934d56e072046e41f",
                "MacAddress": "02:42:ac:14:00:03",
                "IPv4Address": "172.20.0.3/16",
                "IPv6Address": ""
            }
        },
        "Options": {},
        "Labels": {
            "com.docker.compose.network": "default",
            "com.docker.compose.project": "remote-control",
            "com.docker.compose.version": "1.29.2"
        }
    }
]
````

We also see that container on host network are not present here.

Then checking `veth` on host `ip link`

````
root@scoulomb-HP-Pavilion-TS-Sleekbook-14:~# ip link show | grep -A 3  docker
11: docker0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN mode DEFAULT group default
    link/ether 02:42:20:60:c7:6a brd ff:ff:ff:ff:ff:ff
12: flannel.1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue state UNKNOWN mode DEFAULT group default
    link/ether b6:3f:0b:e4:56:fd brd ff:ff:ff:ff:ff:ff

root@scoulomb-HP-Pavilion-TS-Sleekbook-14:~# ip link show | grep -A 3  5c12fb711107
8: br-5c12fb711107: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue state UP mode DEFAULT group default
    link/ether 02:42:07:f6:24:e1 brd ff:ff:ff:ff:ff:ff
9: br-6208c1507ce0: <NO-CARRIER,BROADCAST,MULTICAST,UP> mtu 1500 qdisc noqueue state DOWN mode DEFAULT group default
    link/ether 02:42:f1:e2:83:d2 brd ff:ff:ff:ff:ff:ff
--
77: vethbc377ad@if76: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master br-5c12fb711107 state UP mode DEFAULT group default
    link/ether 42:fe:2c:8a:f2:8c brd ff:ff:ff:ff:ff:ff link-netnsid 20
79: veth23d46a5@if78: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc noqueue master br-5c12fb711107 state UP mode DEFAULT group default
    link/ether d6:6d:32:e1:31:f9 brd ff:ff:ff:ff:ff:ff link-netnsid 21
root@scoulomb-HP-Pavilion-TS-Sleekbook-14:~#
````

We can cleary see the 2veth (vethbc377ad, veth23d46a5) in same docker nw 5c12fb711107. 

And `ifconfig`

````
root@scoulomb-HP-Pavilion-TS-Sleekbook-14:~# ifconfig | grep -C 5 docker
        RX packets 220098  bytes 40129086 (40.1 MB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 243031  bytes 47407090 (47.4 MB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

docker0: flags=4099<UP,BROADCAST,MULTICAST>  mtu 1500
        inet 172.17.0.1  netmask 255.255.0.0  broadcast 172.17.255.255
        inet6 fe80::42:20ff:fe60:c76a  prefixlen 64  scopeid 0x20<link>
        ether 02:42:20:60:c7:6a  txqueuelen 0  (Ethernet)
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
root@scoulomb-HP-Pavilion-TS-Sleekbook-14:~#
root@scoulomb-HP-Pavilion-TS-Sleekbook-14:~# ifconfig | grep -C 5 5c12fb711107
        RX packets 0  bytes 0 (0.0 B)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 0  bytes 0 (0.0 B)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0

br-5c12fb711107: flags=4163<UP,BROADCAST,RUNNING,MULTICAST>  mtu 1500
        inet 172.20.0.1  netmask 255.255.0.0  broadcast 172.20.255.255
        inet6 fe80::42:7ff:fef6:24e1  prefixlen 64  scopeid 0x20<link>
        ether 02:42:07:f6:24:e1  txqueuelen 0  (Ethernet)
        RX packets 20  bytes 1039 (1.0 KB)
        RX errors 0  dropped 0  overruns 0  frame 0
root@scoulomb-HP-Pavilion-TS-Sleekbook-14:~#
````


We have a veth “tunnel” (a bi-directional connection between each container namespace and the bridge (here custom default network created by compose `5c12fb711107`) (it could be `default` (`docker0`) instead).

See schema in https://argus-sec.com/docker-networking-behind-the-scenes/ 

![docker com](media/docker-com.png)

#### Docker and kernel networking

Inspired from: https://argus-sec.com/docker-networking-behind-the-scenes/

How can containers transfer data to the kernel, and from there, to the outside world? Let’s take a closer look at the process as we cover two network manipulation techniques that Docker uses to achieve its external communication capability:

- Port Forwarding — forwards traffic on a specific port from a container to the kernel.
- Host Networking — disables the network namespace stack isolation from the Docker host.

##### Port forwarding 

###### Observations 

From host we can target `localhost:8000`, where workload is in container.

````

coulomb@scoulomb-HP-Pavilion-TS-Sleekbook-14:~/heos/open-denon-heos/remote-control$ cat PRD.docker-compose.yaml | grep -C 4  8000
    network_mode: host
  remote-control:
    image: scoulomb/heos-remote-control:1.0.0
    ports:
      - 8000:80
  python:
    image: python
    command: sleep 6000
    ports:

scoulomb@scoulomb-HP-Pavilion-TS-Sleekbook-14:~/heos/open-denon-heos/remote-control$ curl localhost:8000 | head -n 10
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
10<!DOCTYPE html>  0    0     0      0      0 --:--:-- --:--:-- --:--:--     0
0 <html lang="en">
1  <head>
04    <meta charset="utf-8" />
05    <meta name="viewport" content="width=device-width, initial-scale=1" />
      <meta name="generator" content="GitLab Pages" />
1    <title>HEOS Remote Control</title>
0    <link rel="stylesheet" href="style.css" />
    <script defer="defer" src="script.js"></script>
0  </head>
 10405    0     0   9.9M      0 --:--:-- --:--:-- --:--:--  9.9M
(23) Failed writing body
````


###### Explanations (SNAT/DNAT)

This is because we have a DNAT rule from host to container IP `172.20.0.3:80` (ip found in `docker describe network`)

````
scoulomb@scoulomb-HP-Pavilion-TS-Sleekbook-14:~/heos/open-denon-heos/remote-control$ sudo iptables -t nat -L -n | grep 8000
# Warning: iptables-legacy tables present, use iptables-legacy to see them
DNAT       tcp  --  0.0.0.0/0            0.0.0.0/0            tcp dpt:8000 to:172.20.0.3:80
MARK       all  --  0.0.0.0/0            0.0.0.0/0            MARK or 0x8000
DNAT       tcp  --  0.0.0.0/0            0.0.0.0/0            /* kube-system/traefik:web */ tcp to:10.42.0.99:8000
````

We can also find the masquerade rule (SNAT) equivalent where container ip is replaced by interface ip for outbound traffic 

````
scoulomb@scoulomb-HP-Pavilion-TS-Sleekbook-14:~/heos/open-denon-heos/remote-control$ sudo iptables -t nat -L -n | grep -C 2 '172.20.0.3\|PREROUTING\|POSROUTING\|DOCKER'
# Warning: iptables-legacy tables present, use iptables-legacy to see them
Chain PREROUTING (policy ACCEPT) # <--------------------------- MASQUERADE
target     prot opt source               destination
KUBE-SERVICES  all  --  0.0.0.0/0            0.0.0.0/0            /* kubernetes service portals */
DOCKER     all  --  0.0.0.0/0            0.0.0.0/0            ADDRTYPE match dst-type LOCAL
CNI-HOSTPORT-DNAT  all  --  0.0.0.0/0            0.0.0.0/0            ADDRTYPE match dst-type LOCAL

--
target     prot opt source               destination
KUBE-SERVICES  all  --  0.0.0.0/0            0.0.0.0/0            /* kubernetes service portals */
DOCKER     all  --  0.0.0.0/0           !127.0.0.0/8          ADDRTYPE match dst-type LOCAL
CNI-HOSTPORT-DNAT  all  --  0.0.0.0/0            0.0.0.0/0            ADDRTYPE match dst-type LOCAL

--
RETURN     all  -- !10.42.0.0/16         10.42.0.0/24         /* flanneld masq */
MASQUERADE  all  -- !10.42.0.0/16         10.42.0.0/16         /* flanneld masq */ random-fully
MASQUERADE  tcp  --  172.20.0.3           172.20.0.3           tcp dpt:80 # <--------------------------- MASQUERADE to gateway IP 

Chain CNI-DN-2ea85681d1400225855f1 (1 references)
--
MARK       all  --  0.0.0.0/0            0.0.0.0/0            /* CNI portfwd masquerade mark */ MARK or 0x2000

Chain DOCKER (2 references)   # <--------------------------- DNAT
target     prot opt source               destination
RETURN     all  --  0.0.0.0/0            0.0.0.0/0
--
RETURN     all  --  0.0.0.0/0            0.0.0.0/0
RETURN     all  --  0.0.0.0/0            0.0.0.0/0
DNAT       tcp  --  0.0.0.0/0            0.0.0.0/0            tcp dpt:8000 to:172.20.0.3:80  # <--------------------------- DNAT

Chain KUBE-FW-CVG3OEGEH7H5P3HQ (1 references)
scoulomb@scoulomb-HP-Pavilion-TS-Sleekbook-14:~/heos/open-denon-heos/remote-control$
````

It is like 
- host machine acts as a traffic from internet,
- Docker bridge network as router 
- and Docker container as machine in the LAN.

We can see  NAT config (`<-------`) 

- POSTROUTING — a new MASQUERADE target was added (it will direct traffic from docker IP (172.20.0.3) to interface IP/docker network bridge IP, here docker IP is `172.20.0.3`, if use docker default it would be `172.17.0.X`), then it will SNAT to an IP of interface: https://unix.stackexchange.com/questions/21967/difference-between-snat-and-masquerade
I suspect source IP and destination IP to be same as use veth, which then is plugged to bridge network? (assumption)
- DOCKER — a new DNAT (destination NAT) target. DNAT is commonly used to publish a service from internal network to an external IP.

So steps are, quoting: https://argus-sec.com/docker-networking-behind-the-scenes/

(I adapt step from original doc, where I use custom defaut network created by compose and original doc use default network.)

1. The http GET request went up from the application layer to the transport layer (TCP request).
2. The http destination IP is localhost (the DNS resolver will interpret it as 127.0.0.1). The source IP is also localhost, and therefore the request is sent on the loopback interface.
3.As for the PREROUTING NAT rule – for any IP (including 127.0.0.1), an interface (e.g. loopback) chains the request to the DOCKER target.
4. In the DOCKER chain there is a DNAT rule. The rule alters the packet destination to 172.20.0.3:80 (original doc:172.17.0.2:5000).
5. The POSTROUTING rule masquerades packets with source IP 172.20.0.3 and port 80 (original doc:172.17.0.2 and port 5000) by changing the source IP to the interface IP. As a result of this modification, the packet transfers through the custom bridge interface (can be the custom default by compose) or docker0 interface (original doc: docker0 interface).
6. Now, the packet has arrived at the  custom bridge (original doc:docker0) interface (after rules 3+5 were applied on the packet). With the support of the veth tunnel, the gateway IP (172.20.0.1) (original doc:"172.17.0.1" which is the ip of docker0/docker default gateway, docker network inspect bridge), which is effectively the packet source) now establishes a TCP connection with the container IP (172.20.0.3)(original doc:172.17.0.2).
7. The webserver binds IP 0.0.0.0 and listens to port 5000, therefore it receives all the frames on its eth0 interface and answers the request.
From there, it generally goes in the opposite direction.
`

Note we can have this command drunning in parallel because different network ns, even if compose in running on port 8000
````
# ip netns add ns1
# ip netns exec ns1 python3 -m http.server 8000
Serving HTTP on :: port 8000 (http://[::]:8000/) ...
````


#### Host network


We have both container and host sharing same network namespace thus we can do 


````
root@scoulomb-HP-Pavilion-TS-Sleekbook-14:~# curl localhost:5000 |head -n 5
  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100  2660  100  2660    0     0  1298k      0 --:--:-- --:--:-- --:--:-- 1298k
<html>
  <head>
  </head>
  <body>
    <h1>Some sample commands</h1>
root@scoulomb-HP-Pavilion-TS-Sleekbook-14:~#
````
We have no specific iptable rules.

<!--

But we have

````
scoulomb@scoulomb-HP-Pavilion-TS-Sleekbook-14:~/heos/open-denon-heos/remote-control$ sudo iptables -t nat -L -n | grep '172.17.0.0'
# Warning: iptables-legacy tables present, use iptables-legacy to see them
MASQUERADE  all  --  172.17.0.0/16        0.0.0.0/0
````

I think this part in:https://argus-sec.com/docker-networking-behind-the-scenes/ is wrong, no SNAT applies we are in same namespace

''''
Stages 1–3 remain as in the port forwarding pipeline.

1. The DOCKER chain only has a RETURN target for any IP, so no rule applied here and the rule returns the routing decision to the caller target.
2. The POSTROUTING rule masquerades all the packets source IP on subnet 172.17.0.0/16 to the interface inet, the loopback interface IP (127.0.0.1).
3. We are left with the source IP 127.0.0.1 and destination IP 0.0.0.0 on port 5000, in the same network stack, which leaves the packet in the loopback interface and the webserver running as it would run on the OS kernel itself.
''''

Moreover a container on host nw does not have IP @

````
root@scoulomb-HP-Pavilion-TS-Sleekbook-14:~# docker ps
CONTAINER ID   IMAGE                                COMMAND                  CREATED       STATUS       PORTS                                             NAMES
bbf2fc3f3aa9   scoulomb/heos-remote-control:1.0.0   "apache2-foreground"     4 hours ago   Up 3 hours   8000/tcp, 0.0.0.0:8000->80/tcp, :::8000->80/tcp   remote-control_remote-control_1
13457ba25650   scoulomb/heos-api-server:1.0.0       "flask run --port 50…"   6 hours ago   Up 3 hours                                                     remote-control_server_1

root@scoulomb-HP-Pavilion-TS-Sleekbook-14:~# docker inspect 13457ba25650  | grep IP
                "PYTHON_PIP_VERSION=22.0.4",
                "PYTHON_GET_PIP_URL=https://github.com/pypa/get-pip/raw/2d26a16e351a22108b46fa11507aa57a732d4074/public/get-pip.py",
                "PYTHON_GET_PIP_SHA256=530e7077f9e31f0378b5ee7cc90c8d99b7aef832f3d4ea96b42c2072e322734e",
            "LinkLocalIPv6Address": "",
            "LinkLocalIPv6PrefixLen": 0,
            "SecondaryIPAddresses": null,
            "SecondaryIPv6Addresses": null,
            "GlobalIPv6Address": "",
            "GlobalIPv6PrefixLen": 0,
            "IPAddress": "",
            "IPPrefixLen": 0,
            "IPv6Gateway": "",
                    "IPAMConfig": null,
                    "IPAddress": "",
                    "IPPrefixLen": 0,
                    "IPv6Gateway": "",
                    "GlobalIPv6Address": "",
                    "GlobalIPv6PrefixLen": 0,
root@scoulomb-HP-Pavilion-TS-Sleekbook-14:~#
root@scoulomb-HP-Pavilion-TS-Sleekbook-14:~# docker ps
CONTAINER ID   IMAGE                                COMMAND                  CREATED       STATUS       PORTS                                             NAMES
bbf2fc3f3aa9   scoulomb/heos-remote-control:1.0.0   "apache2-foreground"     4 hours ago   Up 3 hours   8000/tcp, 0.0.0.0:8000->80/tcp, :::8000->80/tcp   remote-control_remote-control_1
13457ba25650   scoulomb/heos-api-server:1.0.0       "flask run --port 50…"   6 hours ago   Up 3 hours                                                     remote-control_server_1
root@scoulomb-HP-Pavilion-TS-Sleekbook-14:~# docker inspect bbf2fc3f3aa9   | grep IP
            "LinkLocalIPv6Address": "",
            "LinkLocalIPv6PrefixLen": 0,
            "SecondaryIPAddresses": null,
            "SecondaryIPv6Addresses": null,
            "GlobalIPv6Address": "",
            "GlobalIPv6PrefixLen": 0,
            "IPAddress": "",
            "IPPrefixLen": 0,
            "IPv6Gateway": "",
                    "IPAMConfig": null,
                    "IPAddress": "172.20.0.3",
                    "IPPrefixLen": 16,
                    "IPv6Gateway": "",
                    "GlobalIPv6Address": "",
                    "GlobalIPv6PrefixLen": 0,
root@scoulomb-HP-Pavilion-TS-Sleekbook-14:~#
````
-->


### Let's explore cgroup namespace


We will add memory limit to our container

````
scoulomb@scoulomb-HP-Pavilion-TS-Sleekbook-14:~/heos/open-denon-heos/remote-control$ cat PRD.docker-compose.yaml up
version: "3.6"
services:
  server:
    image: scoulomb/heos-api-server:1.0.0
    environment:
      - CONF_PLAYER_NAME=Denon AVR-X2700H
      - CONF_USER=fake@gmail.com
      - CONF_PW=do-not-use-qwerty-as-your-password
    network_mode: host
  remote-control:
    image: scoulomb/heos-remote-control:1.0.0
    ports:
      - 8000:80
    deploy:
      resources:
        limits:
          memory: 50M
        reservations:
          memory: 50M
````

<!--
Can find path by putting invalid cpu limit
-->

And see impact on cgroup

````
root@scoulomb-HP-Pavilion-TS-Sleekbook-14:/sys/fs/cgroup/system.slice# docker ps
CONTAINER ID   IMAGE                                COMMAND                  CREATED          STATUS         PORTS                                             NAMES
5b1d3a11b8b3   scoulomb/heos-remote-control:1.0.0   "apache2-foreground"     6 minutes ago    Up 5 minutes   8000/tcp, 0.0.0.0:8000->80/tcp, :::8000->80/tcp   remote-control_remote-control_1
13457ba25650   scoulomb/heos-api-server:1.0.0       "flask run --port 50…"   55 minutes ago   Up 5 minutes                                                     remote-control_server_1

root@scoulomb-HP-Pavilion-TS-Sleekbook-14:/sys/fs/cgroup/system.slice# cat docker-5b1d3a11b8b3ddc6a98da7c69ab03cae089ebdf463bbec0dbf71b150555efa6b.scope/memory.max
52428800
````

50 Mebibytes equals to 52428800 bytes!

We can also find the cgroup by doing

````
# ps -aux | grep flask
root       15146  2.2  0.3  32024 27076 ?        Ss   16:49   0:00 /usr/local/bin/python /usr/local/bin/flask run --port 5000 --host 0.0.0.0
root       15283  0.0  0.0   9264  2412 pts/1    S+   16:49   0:00 grep --color=auto flask
# cat /proc/15146/cgroup
0::/system.slice/docker-13457ba25650af56412514013cdabf7a6eb90fd51af4d87e54fe7625e83c06d5.scope
````

Which is a nice way to find all docker running in same cgroup.


## Docker and kernel


Can we have 2 containers running with different version of the kernel? Answer is no
https://www.edureka.co/community/65179/do-docker-containers-have-their-own-kernel-and-cpu


## Good doc

- https://argus-sec.com/docker-networking-behind-the-scenes/
- https://medium.com/techlog/diving-into-linux-networking-and-docker-bridge-veth-and-iptables-a05eb27b1e72
- <!-- they use vagrant as here: https://github.com/scoulomb/misc-notes/blob/master/lab-env/others.md#use-vagrant-vm  -->

## Links concept

- Link bridge: https://github.com/open-denon-heos/remote-control#default-setup-explanation-in-docker
- Docker dojo: https://github.com/scoulomb/misc-notes/blob/master/lab-env/kubernetes-distribution.md (show docker are normal process)
- [NAT](NAT.md)

<!-- i think we are all good here -->

## Next steps could be 

- https://medium.com/techlog/diving-into-linux-networking-and-docker-bridge-veth-and-iptables-a05eb27b1e72
<!-- optional -->
- Explore more "Solution is to use Docker host gateway which route to host."
<!-- suffit for now -->

- Give a definition of Docker
<!-- Optional JM: check more veth?: searc for "But each networks namespaces is attached to a veth:"-->
<!-- ok ccl -->
<!-- new update OK -->

<!-- reviewed iptable snat juge OK stop and link heos link was/is ok, no recheck, STOP OK YES -->
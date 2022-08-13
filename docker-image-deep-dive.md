# Exploring an Image

Let's create a directory in which we will do everything:

```sh
mkdir fun
cd fun
```

## Pull and save an image as a tarball

```sh
docker pull caddy
```

```
Using default tag: latest
latest: Pulling from library/caddy
213ec9aee27d: Pull complete 
fd0c7d01ba8a: Pull complete 
184e55d8db53: Pull complete 
8bfd93fd8895: Pull complete 
81dbe6c9e2d1: Pull complete 
Digest: sha256:740c1c9e461ea1f8a54d7512b35cd31927c814c86455f71e7e8e0c2b6ee423a2
Status: Downloaded newer image for caddy:latest
docker.io/library/caddy:latest
```

```sh
docker save caddy -o caddy-image.tar
```

```sh
ls -l
```

```
Permissions Size User Date Modified    Name
.rwxrwxrwx   46M root 2022-08-13 10:40 caddy-image.tar
```

## Image structure

```sh
tree caddy-image
```

```
caddy-image
├── 30b3d401f9c31fb7538ac3be1be18d505a4be3575985a56b7c319f4a6970bf07
│   ├── json
│   ├── layer.tar
│   └── VERSION
├── 3e571912155d9bac1a5285bf1c21105bea53585f77a159316eed491882710ab2
│   ├── json
│   ├── layer.tar
│   └── VERSION
├── 743ed904eb393b6d33d22912502e905e4b46e1685fb61d94a4a60c90bf238bf4.json
├── b357a625a3b4594db83c045426614ffb9f753f16cbb03fe8f2fca8907ec54205
│   ├── json
│   ├── layer.tar
│   └── VERSION
├── c0e8e59ce77b7683efb604d1f61d0dbd579c260cf3aef75d96defc9dffedc4a2
│   ├── json
│   ├── layer.tar
│   └── VERSION
├── fcef99b24c1068ac76f5c9f8efb11550254d7f62dcd17a5c39146ec1e00d9b61
│   ├── json
│   ├── layer.tar
│   └── VERSION
├── manifest.json
└── repositories
```

```sh
jq '.' caddy-image/manifest.json
```

```json
[
  {
    "Config": "743ed904eb393b6d33d22912502e905e4b46e1685fb61d94a4a60c90bf238bf4.json",
    "RepoTags": [
      "caddy:latest"
    ],
    "Layers": [
      "3e571912155d9bac1a5285bf1c21105bea53585f77a159316eed491882710ab2/layer.tar",
      "30b3d401f9c31fb7538ac3be1be18d505a4be3575985a56b7c319f4a6970bf07/layer.tar",
      "fcef99b24c1068ac76f5c9f8efb11550254d7f62dcd17a5c39146ec1e00d9b61/layer.tar",
      "b357a625a3b4594db83c045426614ffb9f753f16cbb03fe8f2fca8907ec54205/layer.tar",
      "c0e8e59ce77b7683efb604d1f61d0dbd579c260cf3aef75d96defc9dffedc4a2/layer.tar"
    ]
  }
]
```

## Last layer metadata

```sh
LAST_LAYER=$(jq --raw-output '.[0].Layers[-1]' caddy-image/manifest.json | sed 's/\/layer.tar//g')
```

```sh
jq '.os' caddy-image/$LAST_LAYER/json
```

```json
"linux"
```

```sh
jq '.architecture' caddy-image/$LAST_LAYER/json
```

```json
"amd64"
```

```sh
jq '.config.Labels' caddy-image/$LAST_LAYER/json
```

```json
{
  "org.opencontainers.image.description": "a powerful, enterprise-ready, open source web server with automatic HTTPS written in Go",
  "org.opencontainers.image.documentation": "https://caddyserver.com/docs",
  "org.opencontainers.image.licenses": "Apache-2.0",
  "org.opencontainers.image.source": "https://github.com/caddyserver/caddy-docker",
  "org.opencontainers.image.title": "Caddy",
  "org.opencontainers.image.url": "https://caddyserver.com",
  "org.opencontainers.image.vendor": "Light Code Labs",
  "org.opencontainers.image.version": "v2.5.2"
}
```

```sh
jq '.config.Env' caddy-image/$LAST_LAYER/json
```

```json
[
  "PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin",
  "CADDY_VERSION=v2.5.2",
  "XDG_CONFIG_HOME=/config",
  "XDG_DATA_HOME=/data"
]
```

```sh
jq '.config.Cmd' caddy-image/$LAST_LAYER/json
```

```json
[
  "caddy",
  "run",
  "--config",
  "/etc/caddy/Caddyfile",
  "--adapter",
  "caddyfile"
]
```

## Last layer content

Each layer contains the diff from the previous layer:

```sh
mkdir caddy-image/$LAST_LAYER/last-layer

tar -xf caddy-image/$LAST_LAYER/layer.tar -C ./caddy-image/$LAST_LAYER/last-layer

tree ./caddy-image/$LAST_LAYER/last-layer
```

```
./caddy-image/c0e8e59ce77b7683efb604d1f61d0dbd579c260cf3aef75d96defc9dffedc4a2/last-layer
└── etc
    └── nsswitch.conf
```

## First layer

While the first layer usually contains the base system onto which most of the
other files are added:

```sh
FIRST_LAYER=$(jq --raw-output '.[0].Layers[0]' caddy-image/manifest.json | sed 's/\/layer.tar//g')

mkdir caddy-image/$FIRST_LAYER/first-layer

tar -xf caddy-image/$FIRST_LAYER/layer.tar -C ./caddy-image/$FIRST_LAYER/first-layer

tree ./caddy-image/$FIRST_LAYER/first-layer
```


```
./caddy-image/3e571912155d9bac1a5285bf1c21105bea53585f77a159316eed491882710ab2/first-layer
├── bin
│   ├── arch -> /bin/busybox
│   ├── ash -> /bin/busybox
│   ├── base64 -> /bin/busybox
│   ├── bbconfig -> /bin/busybox
│   ├── busybox
│   ├── cat -> /bin/busybox
│   ├── chattr -> /bin/busybox
│   ├── chgrp -> /bin/busybox
│   ├── chmod -> /bin/busybox
│   ├── chown -> /bin/busybox
│   ├── cp -> /bin/busybox
│   ├── date -> /bin/busybox
│   ├── dd -> /bin/busybox
│   ├── df -> /bin/busybox
│   ├── dmesg -> /bin/busybox
│   ├── dnsdomainname -> /bin/busybox
│   ├── dumpkmap -> /bin/busybox
│   ├── echo -> /bin/busybox
│   ├── ed -> /bin/busybox
│   ├── egrep -> /bin/busybox
│   ├── false -> /bin/busybox
│   ├── fatattr -> /bin/busybox
│   ├── fdflush -> /bin/busybox
│   ├── fgrep -> /bin/busybox
│   ├── fsync -> /bin/busybox
│   ├── getopt -> /bin/busybox
│   ├── grep -> /bin/busybox
│   ├── gunzip -> /bin/busybox
│   ├── gzip -> /bin/busybox
│   ├── hostname -> /bin/busybox
│   ├── ionice -> /bin/busybox
│   ├── iostat -> /bin/busybox
│   ├── ipcalc -> /bin/busybox
│   ├── kbd_mode -> /bin/busybox
│   ├── kill -> /bin/busybox
│   ├── link -> /bin/busybox
│   ├── linux32 -> /bin/busybox
│   ├── linux64 -> /bin/busybox
│   ├── ln -> /bin/busybox
│   ├── login -> /bin/busybox
│   ├── ls -> /bin/busybox
│   ├── lsattr -> /bin/busybox
│   ├── lzop -> /bin/busybox
│   ├── makemime -> /bin/busybox
│   ├── mkdir -> /bin/busybox
│   ├── mknod -> /bin/busybox
│   ├── mktemp -> /bin/busybox
│   ├── more -> /bin/busybox
│   ├── mount -> /bin/busybox
│   ├── mountpoint -> /bin/busybox
│   ├── mpstat -> /bin/busybox
│   ├── mv -> /bin/busybox
│   ├── netstat -> /bin/busybox
│   ├── nice -> /bin/busybox
│   ├── pidof -> /bin/busybox
│   ├── ping -> /bin/busybox
│   ├── ping6 -> /bin/busybox
│   ├── pipe_progress -> /bin/busybox
│   ├── printenv -> /bin/busybox
│   ├── ps -> /bin/busybox
│   ├── pwd -> /bin/busybox
│   ├── reformime -> /bin/busybox
│   ├── rev -> /bin/busybox
│   ├── rm -> /bin/busybox
│   ├── rmdir -> /bin/busybox
│   ├── run-parts -> /bin/busybox
│   ├── sed -> /bin/busybox
│   ├── setpriv -> /bin/busybox
│   ├── setserial -> /bin/busybox
│   ├── sh -> /bin/busybox
│   ├── sleep -> /bin/busybox
│   ├── stat -> /bin/busybox
│   ├── stty -> /bin/busybox
│   ├── su -> /bin/busybox
│   ├── sync -> /bin/busybox
│   ├── tar -> /bin/busybox
│   ├── touch -> /bin/busybox
│   ├── true -> /bin/busybox
│   ├── umount -> /bin/busybox
│   ├── uname -> /bin/busybox
│   ├── usleep -> /bin/busybox
│   ├── watch -> /bin/busybox
│   └── zcat -> /bin/busybox
├── dev
├── etc
│   ├── alpine-release
│   ├── apk
│   │   ├── arch
│   │   ├── keys
│   │   │   ├── alpine-devel@lists.alpinelinux.org-4a6a0840.rsa.pub
│   │   │   ├── alpine-devel@lists.alpinelinux.org-5243ef4b.rsa.pub
│   │   │   ├── alpine-devel@lists.alpinelinux.org-5261cecb.rsa.pub
│   │   │   ├── alpine-devel@lists.alpinelinux.org-6165ee59.rsa.pub
│   │   │   └── alpine-devel@lists.alpinelinux.org-61666e3f.rsa.pub
│   │   ├── protected_paths.d
│   │   ├── repositories
│   │   └── world
│   ├── conf.d
│   ├── crontabs
│   │   └── root
│   ├── fstab
│   ├── group
│   ├── hostname
│   ├── hosts
│   ├── init.d
│   ├── inittab
│   ├── issue
│   ├── logrotate.d
│   │   └── acpid
│   ├── modprobe.d
│   │   ├── aliases.conf
│   │   ├── blacklist.conf
│   │   ├── i386.conf
│   │   └── kms.conf
│   ├── modules
│   ├── modules-load.d
│   ├── motd
│   ├── mtab -> /proc/mounts
│   ├── network
│   │   ├── if-down.d
│   │   ├── if-post-down.d
│   │   ├── if-post-up.d
│   │   ├── if-pre-down.d
│   │   ├── if-pre-up.d
│   │   └── if-up.d
│   │       └── dad
│   ├── opt
│   ├── os-release
│   ├── passwd
│   ├── periodic
│   │   ├── 15min
│   │   ├── daily
│   │   ├── hourly
│   │   ├── monthly
│   │   └── weekly
│   ├── profile
│   ├── profile.d
│   │   ├── color_prompt.sh.disabled
│   │   ├── locale.sh
│   │   └── README
│   ├── protocols
│   ├── secfixes.d
│   │   └── alpine
│   ├── securetty
│   ├── services
│   ├── shadow
│   ├── shells
│   ├── ssl
│   │   ├── cert.pem -> certs/ca-certificates.crt
│   │   ├── certs
│   │   │   └── ca-certificates.crt
│   │   ├── ct_log_list.cnf
│   │   ├── ct_log_list.cnf.dist
│   │   ├── misc
│   │   │   ├── CA.pl
│   │   │   ├── tsget -> tsget.pl
│   │   │   └── tsget.pl
│   │   ├── openssl.cnf
│   │   ├── openssl.cnf.dist
│   │   └── private
│   ├── sysctl.conf
│   ├── sysctl.d
│   └── udhcpd.conf
├── home
├── lib
│   ├── apk
│   │   └── db
│   │       ├── installed
│   │       ├── lock
│   │       ├── scripts.tar
│   │       └── triggers
│   ├── firmware
│   ├── ld-musl-x86_64.so.1
│   ├── libapk.so.3.12.0
│   ├── libc.musl-x86_64.so.1 -> ld-musl-x86_64.so.1
│   ├── libcrypto.so.1.1
│   ├── libssl.so.1.1
│   ├── libz.so.1 -> libz.so.1.2.12
│   ├── libz.so.1.2.12
│   ├── mdev
│   ├── modules-load.d
│   └── sysctl.d
│       └── 00-alpine.conf
├── media
│   ├── cdrom
│   ├── floppy
│   └── usb
├── mnt
├── opt
├── proc
├── root
├── run
├── sbin
│   ├── acpid -> /bin/busybox
│   ├── adjtimex -> /bin/busybox
│   ├── apk
│   ├── arp -> /bin/busybox
│   ├── blkid -> /bin/busybox
│   ├── blockdev -> /bin/busybox
│   ├── depmod -> /bin/busybox
│   ├── fbsplash -> /bin/busybox
│   ├── fdisk -> /bin/busybox
│   ├── findfs -> /bin/busybox
│   ├── fsck -> /bin/busybox
│   ├── fstrim -> /bin/busybox
│   ├── getty -> /bin/busybox
│   ├── halt -> /bin/busybox
│   ├── hwclock -> /bin/busybox
│   ├── ifconfig -> /bin/busybox
│   ├── ifdown -> /bin/busybox
│   ├── ifenslave -> /bin/busybox
│   ├── ifup -> /bin/busybox
│   ├── init -> /bin/busybox
│   ├── inotifyd -> /bin/busybox
│   ├── insmod -> /bin/busybox
│   ├── ip -> /bin/busybox
│   ├── ipaddr -> /bin/busybox
│   ├── iplink -> /bin/busybox
│   ├── ipneigh -> /bin/busybox
│   ├── iproute -> /bin/busybox
│   ├── iprule -> /bin/busybox
│   ├── iptunnel -> /bin/busybox
│   ├── klogd -> /bin/busybox
│   ├── ldconfig
│   ├── loadkmap -> /bin/busybox
│   ├── logread -> /bin/busybox
│   ├── losetup -> /bin/busybox
│   ├── lsmod -> /bin/busybox
│   ├── mdev -> /bin/busybox
│   ├── mkdosfs -> /bin/busybox
│   ├── mkfs.vfat -> /bin/busybox
│   ├── mkmntdirs
│   ├── mkswap -> /bin/busybox
│   ├── modinfo -> /bin/busybox
│   ├── modprobe -> /bin/busybox
│   ├── nameif -> /bin/busybox
│   ├── nologin -> /bin/busybox
│   ├── pivot_root -> /bin/busybox
│   ├── poweroff -> /bin/busybox
│   ├── raidautorun -> /bin/busybox
│   ├── reboot -> /bin/busybox
│   ├── rmmod -> /bin/busybox
│   ├── route -> /bin/busybox
│   ├── setconsole -> /bin/busybox
│   ├── slattach -> /bin/busybox
│   ├── swapoff -> /bin/busybox
│   ├── swapon -> /bin/busybox
│   ├── switch_root -> /bin/busybox
│   ├── sysctl -> /bin/busybox
│   ├── syslogd -> /bin/busybox
│   ├── tunctl -> /bin/busybox
│   ├── udhcpc -> /bin/busybox
│   ├── vconfig -> /bin/busybox
│   └── watchdog -> /bin/busybox
├── srv
├── sys
├── tmp
├── usr
│   ├── bin
│   │   ├── [ -> /bin/busybox
│   │   ├── [[ -> /bin/busybox
│   │   ├── awk -> /bin/busybox
│   │   ├── basename -> /bin/busybox
│   │   ├── bc -> /bin/busybox
│   │   ├── beep -> /bin/busybox
│   │   ├── blkdiscard -> /bin/busybox
│   │   ├── bunzip2 -> /bin/busybox
│   │   ├── bzcat -> /bin/busybox
│   │   ├── bzip2 -> /bin/busybox
│   │   ├── cal -> /bin/busybox
│   │   ├── chvt -> /bin/busybox
│   │   ├── cksum -> /bin/busybox
│   │   ├── clear -> /bin/busybox
│   │   ├── cmp -> /bin/busybox
│   │   ├── comm -> /bin/busybox
│   │   ├── cpio -> /bin/busybox
│   │   ├── crontab -> /bin/busybox
│   │   ├── cryptpw -> /bin/busybox
│   │   ├── cut -> /bin/busybox
│   │   ├── dc -> /bin/busybox
│   │   ├── deallocvt -> /bin/busybox
│   │   ├── diff -> /bin/busybox
│   │   ├── dirname -> /bin/busybox
│   │   ├── dos2unix -> /bin/busybox
│   │   ├── du -> /bin/busybox
│   │   ├── eject -> /bin/busybox
│   │   ├── env -> /bin/busybox
│   │   ├── expand -> /bin/busybox
│   │   ├── expr -> /bin/busybox
│   │   ├── factor -> /bin/busybox
│   │   ├── fallocate -> /bin/busybox
│   │   ├── find -> /bin/busybox
│   │   ├── flock -> /bin/busybox
│   │   ├── fold -> /bin/busybox
│   │   ├── free -> /bin/busybox
│   │   ├── fuser -> /bin/busybox
│   │   ├── getconf
│   │   ├── getent
│   │   ├── groups -> /bin/busybox
│   │   ├── hd -> /bin/busybox
│   │   ├── head -> /bin/busybox
│   │   ├── hexdump -> /bin/busybox
│   │   ├── hostid -> /bin/busybox
│   │   ├── iconv
│   │   ├── id -> /bin/busybox
│   │   ├── install -> /bin/busybox
│   │   ├── ipcrm -> /bin/busybox
│   │   ├── ipcs -> /bin/busybox
│   │   ├── killall -> /bin/busybox
│   │   ├── last -> /bin/busybox
│   │   ├── ldd
│   │   ├── less -> /bin/busybox
│   │   ├── logger -> /bin/busybox
│   │   ├── lsof -> /bin/busybox
│   │   ├── lsusb -> /bin/busybox
│   │   ├── lzcat -> /bin/busybox
│   │   ├── lzma -> /bin/busybox
│   │   ├── lzopcat -> /bin/busybox
│   │   ├── md5sum -> /bin/busybox
│   │   ├── mesg -> /bin/busybox
│   │   ├── microcom -> /bin/busybox
│   │   ├── mkfifo -> /bin/busybox
│   │   ├── mkpasswd -> /bin/busybox
│   │   ├── nc -> /bin/busybox
│   │   ├── nl -> /bin/busybox
│   │   ├── nmeter -> /bin/busybox
│   │   ├── nohup -> /bin/busybox
│   │   ├── nproc -> /bin/busybox
│   │   ├── nsenter -> /bin/busybox
│   │   ├── nslookup -> /bin/busybox
│   │   ├── od -> /bin/busybox
│   │   ├── openvt -> /bin/busybox
│   │   ├── passwd -> /bin/busybox
│   │   ├── paste -> /bin/busybox
│   │   ├── pgrep -> /bin/busybox
│   │   ├── pkill -> /bin/busybox
│   │   ├── pmap -> /bin/busybox
│   │   ├── printf -> /bin/busybox
│   │   ├── pscan -> /bin/busybox
│   │   ├── pstree -> /bin/busybox
│   │   ├── pwdx -> /bin/busybox
│   │   ├── readlink -> /bin/busybox
│   │   ├── realpath -> /bin/busybox
│   │   ├── renice -> /bin/busybox
│   │   ├── reset -> /bin/busybox
│   │   ├── resize -> /bin/busybox
│   │   ├── scanelf
│   │   ├── seq -> /bin/busybox
│   │   ├── setkeycodes -> /bin/busybox
│   │   ├── setsid -> /bin/busybox
│   │   ├── sha1sum -> /bin/busybox
│   │   ├── sha256sum -> /bin/busybox
│   │   ├── sha3sum -> /bin/busybox
│   │   ├── sha512sum -> /bin/busybox
│   │   ├── showkey -> /bin/busybox
│   │   ├── shred -> /bin/busybox
│   │   ├── shuf -> /bin/busybox
│   │   ├── sort -> /bin/busybox
│   │   ├── split -> /bin/busybox
│   │   ├── ssl_client
│   │   ├── strings -> /bin/busybox
│   │   ├── sum -> /bin/busybox
│   │   ├── tac -> /bin/busybox
│   │   ├── tail -> /bin/busybox
│   │   ├── tee -> /bin/busybox
│   │   ├── test -> /bin/busybox
│   │   ├── time -> /bin/busybox
│   │   ├── timeout -> /bin/busybox
│   │   ├── top -> /bin/busybox
│   │   ├── tr -> /bin/busybox
│   │   ├── traceroute -> /bin/busybox
│   │   ├── traceroute6 -> /bin/busybox
│   │   ├── truncate -> /bin/busybox
│   │   ├── tty -> /bin/busybox
│   │   ├── ttysize -> /bin/busybox
│   │   ├── udhcpc6 -> /bin/busybox
│   │   ├── unexpand -> /bin/busybox
│   │   ├── uniq -> /bin/busybox
│   │   ├── unix2dos -> /bin/busybox
│   │   ├── unlink -> /bin/busybox
│   │   ├── unlzma -> /bin/busybox
│   │   ├── unlzop -> /bin/busybox
│   │   ├── unshare -> /bin/busybox
│   │   ├── unxz -> /bin/busybox
│   │   ├── unzip -> /bin/busybox
│   │   ├── uptime -> /bin/busybox
│   │   ├── uudecode -> /bin/busybox
│   │   ├── uuencode -> /bin/busybox
│   │   ├── vi -> /bin/busybox
│   │   ├── vlock -> /bin/busybox
│   │   ├── volname -> /bin/busybox
│   │   ├── wc -> /bin/busybox
│   │   ├── wget -> /bin/busybox
│   │   ├── which -> /bin/busybox
│   │   ├── who -> /bin/busybox
│   │   ├── whoami -> /bin/busybox
│   │   ├── whois -> /bin/busybox
│   │   ├── xargs -> /bin/busybox
│   │   ├── xxd -> /bin/busybox
│   │   ├── xzcat -> /bin/busybox
│   │   └── yes -> /bin/busybox
│   ├── lib
│   │   ├── engines-1.1
│   │   │   ├── afalg.so
│   │   │   ├── capi.so
│   │   │   └── padlock.so
│   │   ├── libcrypto.so.1.1 -> ../../lib/libcrypto.so.1.1
│   │   ├── libssl.so.1.1 -> ../../lib/libssl.so.1.1
│   │   └── modules-load.d
│   ├── local
│   │   ├── bin
│   │   ├── lib
│   │   └── share
│   ├── sbin
│   │   ├── addgroup -> /bin/busybox
│   │   ├── add-shell -> /bin/busybox
│   │   ├── adduser -> /bin/busybox
│   │   ├── arping -> /bin/busybox
│   │   ├── brctl -> /bin/busybox
│   │   ├── chpasswd -> /bin/busybox
│   │   ├── chroot -> /bin/busybox
│   │   ├── crond -> /bin/busybox
│   │   ├── delgroup -> /bin/busybox
│   │   ├── deluser -> /bin/busybox
│   │   ├── ether-wake -> /bin/busybox
│   │   ├── fbset -> /bin/busybox
│   │   ├── killall5 -> /bin/busybox
│   │   ├── loadfont -> /bin/busybox
│   │   ├── nanddump -> /bin/busybox
│   │   ├── nandwrite -> /bin/busybox
│   │   ├── nbd-client -> /bin/busybox
│   │   ├── ntpd -> /bin/busybox
│   │   ├── partprobe -> /bin/busybox
│   │   ├── rdate -> /bin/busybox
│   │   ├── rdev -> /bin/busybox
│   │   ├── readahead -> /bin/busybox
│   │   ├── remove-shell -> /bin/busybox
│   │   ├── rfkill -> /bin/busybox
│   │   ├── sendmail -> /bin/busybox
│   │   ├── setfont -> /bin/busybox
│   │   └── setlogcons -> /bin/busybox
│   └── share
│       ├── apk
│       │   └── keys
│       │       ├── aarch64
│       │       │   ├── alpine-devel@lists.alpinelinux.org-58199dcc.rsa.pub -> ../alpine-devel@lists.alpinelinux.org-58199dcc.rsa.pub
│       │       │   └── alpine-devel@lists.alpinelinux.org-616ae350.rsa.pub -> ../alpine-devel@lists.alpinelinux.org-616ae350.rsa.pub
│       │       ├── alpine-devel@lists.alpinelinux.org-4a6a0840.rsa.pub
│       │       ├── alpine-devel@lists.alpinelinux.org-5243ef4b.rsa.pub
│       │       ├── alpine-devel@lists.alpinelinux.org-524d27bb.rsa.pub
│       │       ├── alpine-devel@lists.alpinelinux.org-5261cecb.rsa.pub
│       │       ├── alpine-devel@lists.alpinelinux.org-58199dcc.rsa.pub
│       │       ├── alpine-devel@lists.alpinelinux.org-58cbb476.rsa.pub
│       │       ├── alpine-devel@lists.alpinelinux.org-58e4f17d.rsa.pub
│       │       ├── alpine-devel@lists.alpinelinux.org-5e69ca50.rsa.pub
│       │       ├── alpine-devel@lists.alpinelinux.org-60ac2099.rsa.pub
│       │       ├── alpine-devel@lists.alpinelinux.org-6165ee59.rsa.pub
│       │       ├── alpine-devel@lists.alpinelinux.org-61666e3f.rsa.pub
│       │       ├── alpine-devel@lists.alpinelinux.org-616a9724.rsa.pub
│       │       ├── alpine-devel@lists.alpinelinux.org-616abc23.rsa.pub
│       │       ├── alpine-devel@lists.alpinelinux.org-616ac3bc.rsa.pub
│       │       ├── alpine-devel@lists.alpinelinux.org-616adfeb.rsa.pub
│       │       ├── alpine-devel@lists.alpinelinux.org-616ae350.rsa.pub
│       │       ├── alpine-devel@lists.alpinelinux.org-616db30d.rsa.pub
│       │       ├── armhf
│       │       │   ├── alpine-devel@lists.alpinelinux.org-524d27bb.rsa.pub -> ../alpine-devel@lists.alpinelinux.org-524d27bb.rsa.pub
│       │       │   └── alpine-devel@lists.alpinelinux.org-616a9724.rsa.pub -> ../alpine-devel@lists.alpinelinux.org-616a9724.rsa.pub
│       │       ├── armv7
│       │       │   ├── alpine-devel@lists.alpinelinux.org-524d27bb.rsa.pub -> ../alpine-devel@lists.alpinelinux.org-524d27bb.rsa.pub
│       │       │   └── alpine-devel@lists.alpinelinux.org-616adfeb.rsa.pub -> ../alpine-devel@lists.alpinelinux.org-616adfeb.rsa.pub
│       │       ├── mips64
│       │       │   └── alpine-devel@lists.alpinelinux.org-5e69ca50.rsa.pub -> ../alpine-devel@lists.alpinelinux.org-5e69ca50.rsa.pub
│       │       ├── ppc64le
│       │       │   ├── alpine-devel@lists.alpinelinux.org-58cbb476.rsa.pub -> ../alpine-devel@lists.alpinelinux.org-58cbb476.rsa.pub
│       │       │   └── alpine-devel@lists.alpinelinux.org-616abc23.rsa.pub -> ../alpine-devel@lists.alpinelinux.org-616abc23.rsa.pub
│       │       ├── riscv64
│       │       │   ├── alpine-devel@lists.alpinelinux.org-60ac2099.rsa.pub -> ../alpine-devel@lists.alpinelinux.org-60ac2099.rsa.pub
│       │       │   └── alpine-devel@lists.alpinelinux.org-616db30d.rsa.pub -> ../alpine-devel@lists.alpinelinux.org-616db30d.rsa.pub
│       │       ├── s390x
│       │       │   ├── alpine-devel@lists.alpinelinux.org-58e4f17d.rsa.pub -> ../alpine-devel@lists.alpinelinux.org-58e4f17d.rsa.pub
│       │       │   └── alpine-devel@lists.alpinelinux.org-616ac3bc.rsa.pub -> ../alpine-devel@lists.alpinelinux.org-616ac3bc.rsa.pub
│       │       ├── x86
│       │       │   ├── alpine-devel@lists.alpinelinux.org-4a6a0840.rsa.pub -> ../alpine-devel@lists.alpinelinux.org-4a6a0840.rsa.pub
│       │       │   ├── alpine-devel@lists.alpinelinux.org-5243ef4b.rsa.pub -> ../alpine-devel@lists.alpinelinux.org-5243ef4b.rsa.pub
│       │       │   └── alpine-devel@lists.alpinelinux.org-61666e3f.rsa.pub -> ../alpine-devel@lists.alpinelinux.org-61666e3f.rsa.pub
│       │       └── x86_64
│       │           ├── alpine-devel@lists.alpinelinux.org-4a6a0840.rsa.pub -> ../alpine-devel@lists.alpinelinux.org-4a6a0840.rsa.pub
│       │           ├── alpine-devel@lists.alpinelinux.org-5261cecb.rsa.pub -> ../alpine-devel@lists.alpinelinux.org-5261cecb.rsa.pub
│       │           └── alpine-devel@lists.alpinelinux.org-6165ee59.rsa.pub -> ../alpine-devel@lists.alpinelinux.org-6165ee59.rsa.pub
│       ├── man
│       ├── misc
│       └── udhcpc
│           └── default.script
└── var
    ├── cache
    │   ├── apk
    │   └── misc
    ├── empty
    ├── lib
    │   ├── apk
    │   ├── misc
    │   └── udhcpd
    ├── local
    ├── lock
    │   └── subsys
    ├── log
    ├── mail
    ├── opt
    ├── run -> /run
    ├── spool
    │   ├── cron
    │   │   └── crontabs -> /etc/crontabs
    │   └── mail -> /var/mail
    └── tmp
```
# Image format 

Objective is to understand better what docker images are.

## Lab setup

This is done via Jupyter, see setup here: https://github.com/scoulomb/misc-notes/blob/master/Jupyter/README.md


## Build

We will build and save toto image.
In this image we add a file, add a second file, declare and enviromnment var and remove the first file.



```bash
cd ~/image_format
docker build -t toto -f toto.Dockerfile .
```

    Sending build context to Docker daemon  3.072kB
    Step 1/5 : FROM python
     ---> 930516bcf910
    Step 2/5 : RUN touch /toto_rm.txt
     ---> Using cache
     ---> baeab0eb566e
    Step 3/5 : RUN touch /toto.txt
     ---> Using cache
     ---> f012b37a5a35
    Step 4/5 : ENV tutu toto
     ---> Using cache
     ---> 83750f1b5354
    Step 5/5 : RUN rm -f toto_rm.txt
     ---> Using cache
     ---> 9836ad22cf3f
    Successfully built 9836ad22cf3f
    Successfully tagged toto:latest
    [?2004h




```bash
rm -rf ~/tmp_image_format
mkdir  ~/tmp_image_format
docker save toto >  ~/tmp_image_format/toto.tar
```

    [?2004h[?2004l[?2004l




```bash
ls -l  ~/tmp_image_format/toto.tar
```

    -rw-rw-r-- 1 scoulomb scoulomb 941896704 août  16 14:42 [0m[01;31m/home/scoulomb/tmp_image_format/toto.tar[0m
    [?2004h



## Docker image structure

We can uncompress the tarball and observe the content.



```bash
# untar the file
rm -rf  ~/tmp_image_format/toto_tar_uncompress
mkdir ~/tmp_image_format/toto_tar_uncompress
tar -xf ~/tmp_image_format/toto.tar -C ~/tmp_image_format/toto_tar_uncompress
tree  ~/tmp_image_format/toto_tar_uncompress # ll  ~/tmp_image_format/toto_tar_uncompress
```

    [01;34m/home/scoulomb/tmp_image_format/toto_tar_uncompress[00m
    ├── [01;34m22f0d7c7bfdfcb59806e14be3e83d85f92a3bb7604e072922b109eaedd84100b[00m
    │   ├── json
    │   ├── [01;31mlayer.tar[00m
    │   └── VERSION
    ├── [01;34m300b272b0214adc3c331f206bb0b863fdbfac74276ebb51412eca4b2ae5ffae9[00m
    │   ├── json
    │   ├── [01;31mlayer.tar[00m
    │   └── VERSION
    ├── [01;34m54ff2caf5f99d9b81c3a0b5acee2107941c3075490d2f8abf8b718a24d567e93[00m
    │   ├── json
    │   ├── [01;31mlayer.tar[00m
    │   └── VERSION
    ├── [01;34m7f24e93677d0c5f66a08ecf936dd73d47fc14c75e28c18c2d03181bcdbe912a5[00m
    │   ├── json
    │   ├── [01;31mlayer.tar[00m
    │   └── VERSION
    ├── [01;34m8844a0ee96bb354a4033cc08797d144eeee1ee3c8c2ae2682e78459b38279bd1[00m
    │   ├── json
    │   ├── [01;31mlayer.tar[00m
    │   └── VERSION
    ├── [01;34m8ed0edc8e61650e2ef4969d954822efb39304884d46c898864398185d58ffa12[00m
    │   ├── json
    │   ├── [01;31mlayer.tar[00m
    │   └── VERSION
    ├── 9836ad22cf3fcab17b4ad58ba324bc06dd518986346ee5313e42d3dfa0a769da.json
    ├── [01;34maa93f3a87b7fa38394c5550145bdc9debf3915b860ea509444df8eb5ccd58a72[00m
    │   ├── json
    │   ├── [01;31mlayer.tar[00m
    │   └── VERSION
    ├── [01;34mb6d06422210ef192cf5f56712d7284fd45121d86a79ea9cc3c89fc2928d7ce42[00m
    │   ├── json
    │   ├── [01;31mlayer.tar[00m
    │   └── VERSION
    ├── [01;34mc7908f9982db9bd94c7f6ee7f4a3ca72b9341c81c1029a2119d6082a96d8d2f1[00m
    │   ├── json
    │   ├── [01;31mlayer.tar[00m
    │   └── VERSION
    ├── [01;34me6be1d18b1e08a70a496a691e5aba4a0c5d5999db6a155af14ad222232e8be67[00m
    │   ├── json
    │   ├── [01;31mlayer.tar[00m
    │   └── VERSION
    ├── [01;34mf2fdb508d5ca36888d959b93f2083c418ff80b746ea45b0f90586260e24e78e3[00m
    │   ├── json
    │   ├── [01;31mlayer.tar[00m
    │   └── VERSION
    ├── [01;34mfd82dabe7bf1a1a3310eb40654709ea6a7efd1d9d7b844394558b306629677c5[00m
    │   ├── json
    │   ├── [01;31mlayer.tar[00m
    │   └── VERSION
    ├── manifest.json
    └── repositories
    
    12 directories, 39 files
    [?2004h



On `manifest.json` we have the details of each layer. It is pointing to a `layer` folder contained in same archive.


```bash
cat ~/tmp_image_format/toto_tar_uncompress/manifest.json | jq
```

    [1;39m[
      [1;39m{
        [0m[34;1m"Config"[0m[1;39m: [0m[0;32m"9836ad22cf3fcab17b4ad58ba324bc06dd518986346ee5313e42d3dfa0a769da.json"[0m[1;39m,
        [0m[34;1m"RepoTags"[0m[1;39m: [0m[1;39m[
          [0;32m"toto:latest"[0m[1;39m
        [1;39m][0m[1;39m,
        [0m[34;1m"Layers"[0m[1;39m: [0m[1;39m[
          [0;32m"300b272b0214adc3c331f206bb0b863fdbfac74276ebb51412eca4b2ae5ffae9/layer.tar"[0m[1;39m,
          [0;32m"aa93f3a87b7fa38394c5550145bdc9debf3915b860ea509444df8eb5ccd58a72/layer.tar"[0m[1;39m,
          [0;32m"e6be1d18b1e08a70a496a691e5aba4a0c5d5999db6a155af14ad222232e8be67/layer.tar"[0m[1;39m,
          [0;32m"c7908f9982db9bd94c7f6ee7f4a3ca72b9341c81c1029a2119d6082a96d8d2f1/layer.tar"[0m[1;39m,
          [0;32m"b6d06422210ef192cf5f56712d7284fd45121d86a79ea9cc3c89fc2928d7ce42/layer.tar"[0m[1;39m,
          [0;32m"8844a0ee96bb354a4033cc08797d144eeee1ee3c8c2ae2682e78459b38279bd1/layer.tar"[0m[1;39m,
          [0;32m"fd82dabe7bf1a1a3310eb40654709ea6a7efd1d9d7b844394558b306629677c5/layer.tar"[0m[1;39m,
          [0;32m"f2fdb508d5ca36888d959b93f2083c418ff80b746ea45b0f90586260e24e78e3/layer.tar"[0m[1;39m,
          [0;32m"8ed0edc8e61650e2ef4969d954822efb39304884d46c898864398185d58ffa12/layer.tar"[0m[1;39m,
          [0;32m"7f24e93677d0c5f66a08ecf936dd73d47fc14c75e28c18c2d03181bcdbe912a5/layer.tar"[0m[1;39m,
          [0;32m"54ff2caf5f99d9b81c3a0b5acee2107941c3075490d2f8abf8b718a24d567e93/layer.tar"[0m[1;39m,
          [0;32m"22f0d7c7bfdfcb59806e14be3e83d85f92a3bb7604e072922b109eaedd84100b/layer.tar"[0m[1;39m
        [1;39m][0m[1;39m
      [1;39m}[0m[1;39m
    [1;39m][0m
    [?2004h




```bash
cat ~/tmp_image_format/toto_tar_uncompress/repositories
```

    {"toto":{"latest":"22f0d7c7bfdfcb59806e14be3e83d85f92a3bb7604e072922b109eaedd84100b"}}
    [?2004h



While repositories contains info of last layer and in particular tagging information, and sha of last layer.
Equivalent to 


```bash
cat ~/tmp_image_format/toto_tar_uncompress/manifest.json | jq --raw-output '.[0].Layers[-1]'
```

    22f0d7c7bfdfcb59806e14be3e83d85f92a3bb7604e072922b109eaedd84100b/layer.tar
    [?2004h



## Exploring layers

### Methods (optional read)

#### Method 1: use repositories (works only for first layer)


```bash
rm -rf ~/tmp_image_format/layer_1_uncompress
mkdir ~/tmp_image_format/layer_1_uncompress
tar -xf  ~/tmp_image_format/toto_tar_uncompress/$(cat ~/tmp_image_format/toto_tar_uncompress/repositories | jq .toto.latest | tr -d '"')/layer.tar -C ~/tmp_image_format/layer_1_uncompress
ll ~/tmp_image_format/layer_1_uncompress
```

    total 8h[?2004l[?2004l[?2004l
    drwxrwxr-x 2 scoulomb scoulomb 4096 août  16 14:42 [0m[01;34m.[0m/
    drwxrwxr-x 4 scoulomb scoulomb 4096 août  16 14:42 [01;34m..[0m/
    -rw------- 1 scoulomb scoulomb    0 août  16 12:38 .wh.toto_rm.txt
    [?2004h



#### Method 2: use manifest file


```bash
rm -rf ~/tmp_image_format/layer_1_uncompress
mkdir ~/tmp_image_format/layer_1_uncompress

# export card_layers=$(cat ~/tmp_image_format/toto_tar_uncompress/manifest.json | jq -r '.[0].Layers | length')
# echo "Number of layers"
# echo $(expr $card_layers) => Use https://github.com/stedolan/jq/issues/509

tar -xf  ~/tmp_image_format/toto_tar_uncompress/$(cat ~/tmp_image_format/toto_tar_uncompress/manifest.json | jq  '.[0].Layers[-1]' | tr -d '"') -C ~/tmp_image_format/layer_1_uncompress
ll ~/tmp_image_format/layer_1_uncompress
```

    total 8h[?2004l[?2004l[?2004l[?2004l[?2004l[?2004l[?2004l[?2004l
    drwxrwxr-x 2 scoulomb scoulomb 4096 août  16 14:43 [0m[01;34m.[0m/
    drwxrwxr-x 4 scoulomb scoulomb 4096 août  16 14:43 [01;34m..[0m/
    -rw------- 1 scoulomb scoulomb    0 août  16 12:38 .wh.toto_rm.txt
    [?2004h



#### Method 3: use manifest file and JQ the rigth way


```bash
LAST_LAYER=$(jq --raw-output '.[0].Layers[-1]'  ~/tmp_image_format/toto_tar_uncompress/manifest.json | sed 's/\/layer.tar//g')
echo $LAST_LAYER

rm -rf ~/tmp_image_format/layer_1_uncompress
mkdir ~/tmp_image_format/layer_1_uncompress

tar -xf  ~/tmp_image_format/toto_tar_uncompress/$LAST_LAYER/layer.tar -C ~/tmp_image_format/layer_1_uncompress
ll ~/tmp_image_format/layer_1_uncompress

```

    22f0d7c7bfdfcb59806e14be3e83d85f92a3bb7604e072922b109eaedd84100b
    total 8h[?2004l[?2004l[?2004l[?2004l[?2004l[?2004l
    drwxrwxr-x 2 scoulomb scoulomb 4096 août  16 14:43 [0m[01;34m.[0m/
    drwxrwxr-x 4 scoulomb scoulomb 4096 août  16 14:43 [01;34m..[0m/
    -rw------- 1 scoulomb scoulomb    0 août  16 12:38 .wh.toto_rm.txt
    [?2004h



### Layers




```bash
for i in {1..13..1}
do
    echo -e "========================================================================================================"

    export LAYER_INDEX=-$i
    LAYER=$(jq --raw-output ".[0].Layers[$LAYER_INDEX]"  ~/tmp_image_format/toto_tar_uncompress/manifest.json | sed 's/\/layer.tar//g')

    echo "== Showing layer $LAYER with index $LAYER_INDEX"

    echo "=== json"
    cat  ~/tmp_image_format/toto_tar_uncompress/$LAYER/json  | jq 

    echo "=== VERSION"
    cat  ~/tmp_image_format/toto_tar_uncompress/$LAYER/VERSION 

    echo -e "\n"

    echo "=== Tarball content"

    rm -rf ~/tmp_image_format/layer_uncompress/$LAYER_INDEX
    mkdir -p ~/tmp_image_format/layer_uncompress/$LAYER_INDEX

    tar -xf  ~/tmp_image_format/toto_tar_uncompress/$LAYER/layer.tar -C ~/tmp_image_format/layer_uncompress/$LAYER_INDEX
    ll  ~/tmp_image_format/layer_uncompress/$LAYER_INDEX

done


```

    ========================================================================================================[?2004l[?2004l[?2004l[?2004l[?2004l[?2004l[?2004l[?2004l[?2004l[?2004l[?2004l[?2004l[?2004l
    == Showing layer 22f0d7c7bfdfcb59806e14be3e83d85f92a3bb7604e072922b109eaedd84100b with index -1
    === json
    [1;39m{
      [0m[34;1m"id"[0m[1;39m: [0m[0;32m"22f0d7c7bfdfcb59806e14be3e83d85f92a3bb7604e072922b109eaedd84100b"[0m[1;39m,
      [0m[34;1m"parent"[0m[1;39m: [0m[0;32m"54ff2caf5f99d9b81c3a0b5acee2107941c3075490d2f8abf8b718a24d567e93"[0m[1;39m,
      [0m[34;1m"created"[0m[1;39m: [0m[0;32m"2022-08-16T10:38:11.774795417Z"[0m[1;39m,
      [0m[34;1m"container"[0m[1;39m: [0m[0;32m"786d45c32c339075ada5e9b7b4b431eaa386d13ceec9ec0812078865c64cec5c"[0m[1;39m,
      [0m[34;1m"container_config"[0m[1;39m: [0m[1;39m{
        [0m[34;1m"Hostname"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"Domainname"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"User"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"AttachStdin"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"AttachStdout"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"AttachStderr"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"Tty"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"OpenStdin"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"StdinOnce"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"Env"[0m[1;39m: [0m[1;39m[
          [0;32m"PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"[0m[1;39m,
          [0;32m"LANG=C.UTF-8"[0m[1;39m,
          [0;32m"GPG_KEY=A035C8C19219BA821ECEA86B64E628F8D684696D"[0m[1;39m,
          [0;32m"PYTHON_VERSION=3.10.5"[0m[1;39m,
          [0;32m"PYTHON_PIP_VERSION=22.0.4"[0m[1;39m,
          [0;32m"PYTHON_SETUPTOOLS_VERSION=58.1.0"[0m[1;39m,
          [0;32m"PYTHON_GET_PIP_URL=https://github.com/pypa/get-pip/raw/6ce3639da143c5d79b44f94b04080abf2531fd6e/public/get-pip.py"[0m[1;39m,
          [0;32m"PYTHON_GET_PIP_SHA256=ba3ab8267d91fd41c58dbce08f76db99f747f716d85ce1865813842bb035524d"[0m[1;39m,
          [0;32m"tutu=toto"[0m[1;39m
        [1;39m][0m[1;39m,
        [0m[34;1m"Cmd"[0m[1;39m: [0m[1;39m[
          [0;32m"/bin/sh"[0m[1;39m,
          [0;32m"-c"[0m[1;39m,
          [0;32m"rm -f toto_rm.txt"[0m[1;39m
        [1;39m][0m[1;39m,
        [0m[34;1m"Image"[0m[1;39m: [0m[0;32m"sha256:83750f1b53541aba92d66746bbfd3e9755b0bb976813e42a0307b71800491441"[0m[1;39m,
        [0m[34;1m"Volumes"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"WorkingDir"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"Entrypoint"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"OnBuild"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"Labels"[0m[1;39m: [0m[1;30mnull[0m[1;39m
      [1;39m}[0m[1;39m,
      [0m[34;1m"docker_version"[0m[1;39m: [0m[0;32m"20.10.7"[0m[1;39m,
      [0m[34;1m"config"[0m[1;39m: [0m[1;39m{
        [0m[34;1m"Hostname"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"Domainname"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"User"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"AttachStdin"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"AttachStdout"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"AttachStderr"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"Tty"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"OpenStdin"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"StdinOnce"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"Env"[0m[1;39m: [0m[1;39m[
          [0;32m"PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"[0m[1;39m,
          [0;32m"LANG=C.UTF-8"[0m[1;39m,
          [0;32m"GPG_KEY=A035C8C19219BA821ECEA86B64E628F8D684696D"[0m[1;39m,
          [0;32m"PYTHON_VERSION=3.10.5"[0m[1;39m,
          [0;32m"PYTHON_PIP_VERSION=22.0.4"[0m[1;39m,
          [0;32m"PYTHON_SETUPTOOLS_VERSION=58.1.0"[0m[1;39m,
          [0;32m"PYTHON_GET_PIP_URL=https://github.com/pypa/get-pip/raw/6ce3639da143c5d79b44f94b04080abf2531fd6e/public/get-pip.py"[0m[1;39m,
          [0;32m"PYTHON_GET_PIP_SHA256=ba3ab8267d91fd41c58dbce08f76db99f747f716d85ce1865813842bb035524d"[0m[1;39m,
          [0;32m"tutu=toto"[0m[1;39m
        [1;39m][0m[1;39m,
        [0m[34;1m"Cmd"[0m[1;39m: [0m[1;39m[
          [0;32m"python3"[0m[1;39m
        [1;39m][0m[1;39m,
        [0m[34;1m"Image"[0m[1;39m: [0m[0;32m"sha256:83750f1b53541aba92d66746bbfd3e9755b0bb976813e42a0307b71800491441"[0m[1;39m,
        [0m[34;1m"Volumes"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"WorkingDir"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"Entrypoint"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"OnBuild"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"Labels"[0m[1;39m: [0m[1;30mnull[0m[1;39m
      [1;39m}[0m[1;39m,
      [0m[34;1m"architecture"[0m[1;39m: [0m[0;32m"amd64"[0m[1;39m,
      [0m[34;1m"os"[0m[1;39m: [0m[0;32m"linux"[0m[1;39m
    [1;39m}[0m
    === VERSION
    1.0
    
    === Tarball content
    total 8
    drwxrwxr-x 2 scoulomb scoulomb 4096 août  16 14:43 [0m[01;34m.[0m/
    drwxrwxr-x 3 scoulomb scoulomb 4096 août  16 14:43 [01;34m..[0m/
    -rw------- 1 scoulomb scoulomb    0 août  16 12:38 .wh.toto_rm.txt
    ========================================================================================================
    == Showing layer 54ff2caf5f99d9b81c3a0b5acee2107941c3075490d2f8abf8b718a24d567e93 with index -2
    === json
    [1;39m{
      [0m[34;1m"id"[0m[1;39m: [0m[0;32m"54ff2caf5f99d9b81c3a0b5acee2107941c3075490d2f8abf8b718a24d567e93"[0m[1;39m,
      [0m[34;1m"parent"[0m[1;39m: [0m[0;32m"7f24e93677d0c5f66a08ecf936dd73d47fc14c75e28c18c2d03181bcdbe912a5"[0m[1;39m,
      [0m[34;1m"created"[0m[1;39m: [0m[0;32m"1970-01-01T01:00:00+01:00"[0m[1;39m,
      [0m[34;1m"container_config"[0m[1;39m: [0m[1;39m{
        [0m[34;1m"Hostname"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"Domainname"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"User"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"AttachStdin"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"AttachStdout"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"AttachStderr"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"Tty"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"OpenStdin"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"StdinOnce"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"Env"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"Cmd"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"Image"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"Volumes"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"WorkingDir"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"Entrypoint"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"OnBuild"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"Labels"[0m[1;39m: [0m[1;30mnull[0m[1;39m
      [1;39m}[0m[1;39m,
      [0m[34;1m"os"[0m[1;39m: [0m[0;32m"linux"[0m[1;39m
    [1;39m}[0m
    === VERSION
    1.0
    
    === Tarball content
    total 8
    drwxrwxr-x 2 scoulomb scoulomb 4096 août  16 14:43 [0m[01;34m.[0m/
    drwxrwxr-x 4 scoulomb scoulomb 4096 août  16 14:43 [01;34m..[0m/
    -rw-r--r-- 1 scoulomb scoulomb    0 août  15 16:25 toto.txt
    ========================================================================================================
    == Showing layer 7f24e93677d0c5f66a08ecf936dd73d47fc14c75e28c18c2d03181bcdbe912a5 with index -3
    === json
    [1;39m{
      [0m[34;1m"id"[0m[1;39m: [0m[0;32m"7f24e93677d0c5f66a08ecf936dd73d47fc14c75e28c18c2d03181bcdbe912a5"[0m[1;39m,
      [0m[34;1m"parent"[0m[1;39m: [0m[0;32m"8ed0edc8e61650e2ef4969d954822efb39304884d46c898864398185d58ffa12"[0m[1;39m,
      [0m[34;1m"created"[0m[1;39m: [0m[0;32m"1970-01-01T01:00:00+01:00"[0m[1;39m,
      [0m[34;1m"container_config"[0m[1;39m: [0m[1;39m{
        [0m[34;1m"Hostname"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"Domainname"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"User"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"AttachStdin"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"AttachStdout"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"AttachStderr"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"Tty"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"OpenStdin"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"StdinOnce"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"Env"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"Cmd"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"Image"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"Volumes"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"WorkingDir"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"Entrypoint"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"OnBuild"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"Labels"[0m[1;39m: [0m[1;30mnull[0m[1;39m
      [1;39m}[0m[1;39m,
      [0m[34;1m"os"[0m[1;39m: [0m[0;32m"linux"[0m[1;39m
    [1;39m}[0m
    === VERSION
    1.0
    
    === Tarball content
    total 8
    drwxrwxr-x 2 scoulomb scoulomb 4096 août  16 14:43 [0m[01;34m.[0m/
    drwxrwxr-x 5 scoulomb scoulomb 4096 août  16 14:43 [01;34m..[0m/
    -rw-r--r-- 1 scoulomb scoulomb    0 août  15 16:25 toto_rm.txt
    ========================================================================================================
    == Showing layer 8ed0edc8e61650e2ef4969d954822efb39304884d46c898864398185d58ffa12 with index -4
    === json
    [1;39m{
      [0m[34;1m"id"[0m[1;39m: [0m[0;32m"8ed0edc8e61650e2ef4969d954822efb39304884d46c898864398185d58ffa12"[0m[1;39m,
      [0m[34;1m"parent"[0m[1;39m: [0m[0;32m"f2fdb508d5ca36888d959b93f2083c418ff80b746ea45b0f90586260e24e78e3"[0m[1;39m,
      [0m[34;1m"created"[0m[1;39m: [0m[0;32m"1970-01-01T01:00:00+01:00"[0m[1;39m,
      [0m[34;1m"container_config"[0m[1;39m: [0m[1;39m{
        [0m[34;1m"Hostname"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"Domainname"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"User"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"AttachStdin"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"AttachStdout"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"AttachStderr"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"Tty"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"OpenStdin"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"StdinOnce"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"Env"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"Cmd"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"Image"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"Volumes"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"WorkingDir"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"Entrypoint"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"OnBuild"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"Labels"[0m[1;39m: [0m[1;30mnull[0m[1;39m
      [1;39m}[0m[1;39m,
      [0m[34;1m"os"[0m[1;39m: [0m[0;32m"linux"[0m[1;39m
    [1;39m}[0m
    === VERSION
    1.0
    
    === Tarball content
    total 20
    drwxrwxr-x 5 scoulomb scoulomb 4096 août  16 14:43 [0m[01;34m.[0m/
    drwxrwxr-x 6 scoulomb scoulomb 4096 août  16 14:43 [01;34m..[0m/
    drwx------ 2 scoulomb scoulomb 4096 juil. 12 13:28 [01;34mroot[0m/
    drwxrwxr-x 2 scoulomb scoulomb 4096 juil. 12 13:34 [01;34mtmp[0m/
    drwxr-xr-x 3 scoulomb scoulomb 4096 juil. 11 02:00 [01;34musr[0m/
    ========================================================================================================
    == Showing layer f2fdb508d5ca36888d959b93f2083c418ff80b746ea45b0f90586260e24e78e3 with index -5
    === json
    [1;39m{
      [0m[34;1m"id"[0m[1;39m: [0m[0;32m"f2fdb508d5ca36888d959b93f2083c418ff80b746ea45b0f90586260e24e78e3"[0m[1;39m,
      [0m[34;1m"parent"[0m[1;39m: [0m[0;32m"fd82dabe7bf1a1a3310eb40654709ea6a7efd1d9d7b844394558b306629677c5"[0m[1;39m,
      [0m[34;1m"created"[0m[1;39m: [0m[0;32m"1970-01-01T01:00:00+01:00"[0m[1;39m,
      [0m[34;1m"container_config"[0m[1;39m: [0m[1;39m{
        [0m[34;1m"Hostname"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"Domainname"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"User"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"AttachStdin"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"AttachStdout"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"AttachStderr"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"Tty"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"OpenStdin"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"StdinOnce"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"Env"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"Cmd"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"Image"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"Volumes"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"WorkingDir"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"Entrypoint"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"OnBuild"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"Labels"[0m[1;39m: [0m[1;30mnull[0m[1;39m
      [1;39m}[0m[1;39m,
      [0m[34;1m"os"[0m[1;39m: [0m[0;32m"linux"[0m[1;39m
    [1;39m}[0m
    === VERSION
    1.0
    
    === Tarball content
    total 12
    drwxrwxr-x 3 scoulomb scoulomb 4096 août  16 14:43 [0m[01;34m.[0m/
    drwxrwxr-x 7 scoulomb scoulomb 4096 août  16 14:43 [01;34m..[0m/
    drwxr-xr-x 3 scoulomb scoulomb 4096 juil. 11 02:00 [01;34musr[0m/
    ========================================================================================================
    == Showing layer fd82dabe7bf1a1a3310eb40654709ea6a7efd1d9d7b844394558b306629677c5 with index -6
    === json
    [1;39m{
      [0m[34;1m"id"[0m[1;39m: [0m[0;32m"fd82dabe7bf1a1a3310eb40654709ea6a7efd1d9d7b844394558b306629677c5"[0m[1;39m,
      [0m[34;1m"parent"[0m[1;39m: [0m[0;32m"8844a0ee96bb354a4033cc08797d144eeee1ee3c8c2ae2682e78459b38279bd1"[0m[1;39m,
      [0m[34;1m"created"[0m[1;39m: [0m[0;32m"1970-01-01T01:00:00+01:00"[0m[1;39m,
      [0m[34;1m"container_config"[0m[1;39m: [0m[1;39m{
        [0m[34;1m"Hostname"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"Domainname"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"User"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"AttachStdin"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"AttachStdout"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"AttachStderr"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"Tty"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"OpenStdin"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"StdinOnce"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"Env"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"Cmd"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"Image"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"Volumes"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"WorkingDir"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"Entrypoint"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"OnBuild"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"Labels"[0m[1;39m: [0m[1;30mnull[0m[1;39m
      [1;39m}[0m[1;39m,
      [0m[34;1m"os"[0m[1;39m: [0m[0;32m"linux"[0m[1;39m
    [1;39m}[0m
    === VERSION
    1.0
    
    === Tarball content
    total 28
    drwxrwxr-x 7 scoulomb scoulomb 4096 août  16 14:43 [0m[01;34m.[0m/
    drwxrwxr-x 8 scoulomb scoulomb 4096 août  16 14:43 [01;34m..[0m/
    drwxr-xr-x 2 scoulomb scoulomb 4096 juil. 12 13:34 [01;34metc[0m/
    drwx------ 2 scoulomb scoulomb 4096 juil. 12 13:28 [01;34mroot[0m/
    drwxrwxr-x 2 scoulomb scoulomb 4096 juil. 12 13:34 [01;34mtmp[0m/
    drwxr-xr-x 5 scoulomb scoulomb 4096 juil. 11 02:00 [01;34musr[0m/
    drwxr-xr-x 3 scoulomb scoulomb 4096 juil. 11 02:00 [01;34mvar[0m/
    ========================================================================================================
    == Showing layer 8844a0ee96bb354a4033cc08797d144eeee1ee3c8c2ae2682e78459b38279bd1 with index -7
    === json
    [1;39m{
      [0m[34;1m"id"[0m[1;39m: [0m[0;32m"8844a0ee96bb354a4033cc08797d144eeee1ee3c8c2ae2682e78459b38279bd1"[0m[1;39m,
      [0m[34;1m"parent"[0m[1;39m: [0m[0;32m"b6d06422210ef192cf5f56712d7284fd45121d86a79ea9cc3c89fc2928d7ce42"[0m[1;39m,
      [0m[34;1m"created"[0m[1;39m: [0m[0;32m"1970-01-01T01:00:00+01:00"[0m[1;39m,
      [0m[34;1m"container_config"[0m[1;39m: [0m[1;39m{
        [0m[34;1m"Hostname"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"Domainname"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"User"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"AttachStdin"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"AttachStdout"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"AttachStderr"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"Tty"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"OpenStdin"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"StdinOnce"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"Env"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"Cmd"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"Image"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"Volumes"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"WorkingDir"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"Entrypoint"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"OnBuild"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"Labels"[0m[1;39m: [0m[1;30mnull[0m[1;39m
      [1;39m}[0m[1;39m,
      [0m[34;1m"os"[0m[1;39m: [0m[0;32m"linux"[0m[1;39m
    [1;39m}[0m
    === VERSION
    1.0
    
    === Tarball content
    total 24
    drwxrwxr-x 6 scoulomb scoulomb 4096 août  16 14:43 [0m[01;34m.[0m/
    drwxrwxr-x 9 scoulomb scoulomb 4096 août  16 14:43 [01;34m..[0m/
    drwxr-xr-x 2 scoulomb scoulomb 4096 juil. 12 12:23 [01;34metc[0m/
    drwxrwxr-x 2 scoulomb scoulomb 4096 juil. 12 12:23 [01;34mtmp[0m/
    drwxr-xr-x 6 scoulomb scoulomb 4096 juil. 11 02:00 [01;34musr[0m/
    drwxr-xr-x 5 scoulomb scoulomb 4096 juil. 11 02:00 [01;34mvar[0m/
    ========================================================================================================
    == Showing layer b6d06422210ef192cf5f56712d7284fd45121d86a79ea9cc3c89fc2928d7ce42 with index -8
    === json
    [1;39m{
      [0m[34;1m"id"[0m[1;39m: [0m[0;32m"b6d06422210ef192cf5f56712d7284fd45121d86a79ea9cc3c89fc2928d7ce42"[0m[1;39m,
      [0m[34;1m"parent"[0m[1;39m: [0m[0;32m"c7908f9982db9bd94c7f6ee7f4a3ca72b9341c81c1029a2119d6082a96d8d2f1"[0m[1;39m,
      [0m[34;1m"created"[0m[1;39m: [0m[0;32m"1970-01-01T01:00:00+01:00"[0m[1;39m,
      [0m[34;1m"container_config"[0m[1;39m: [0m[1;39m{
        [0m[34;1m"Hostname"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"Domainname"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"User"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"AttachStdin"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"AttachStdout"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"AttachStderr"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"Tty"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"OpenStdin"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"StdinOnce"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"Env"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"Cmd"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"Image"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"Volumes"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"WorkingDir"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"Entrypoint"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"OnBuild"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"Labels"[0m[1;39m: [0m[1;30mnull[0m[1;39m
      [1;39m}[0m[1;39m,
      [0m[34;1m"os"[0m[1;39m: [0m[0;32m"linux"[0m[1;39m
    [1;39m}[0m
    === VERSION
    1.0
    
    === Tarball content
    total 32
    drwxrwxr-x  8 scoulomb scoulomb 4096 août  16 14:43 [0m[01;34m.[0m/
    drwxrwxr-x 10 scoulomb scoulomb 4096 août  16 14:43 [01;34m..[0m/
    drwxr-xr-x  2 scoulomb scoulomb 4096 juil. 12 04:48 [01;34mbin[0m/
    drwxr-xr-x 11 scoulomb scoulomb 4096 juil. 12 04:49 [01;34metc[0m/
    drwxr-xr-x  3 scoulomb scoulomb 4096 juil. 12 04:49 [01;34mlib[0m/
    drwxrwxr-x  2 scoulomb scoulomb 4096 juil. 12 04:48 [01;34mtmp[0m/
    drwxr-xr-x  8 scoulomb scoulomb 4096 juil. 11 02:00 [01;34musr[0m/
    drwxr-xr-x  5 scoulomb scoulomb 4096 juil. 11 02:00 [01;34mvar[0m/
    ========================================================================================================
    == Showing layer c7908f9982db9bd94c7f6ee7f4a3ca72b9341c81c1029a2119d6082a96d8d2f1 with index -9
    === json
    [1;39m{
      [0m[34;1m"id"[0m[1;39m: [0m[0;32m"c7908f9982db9bd94c7f6ee7f4a3ca72b9341c81c1029a2119d6082a96d8d2f1"[0m[1;39m,
      [0m[34;1m"parent"[0m[1;39m: [0m[0;32m"e6be1d18b1e08a70a496a691e5aba4a0c5d5999db6a155af14ad222232e8be67"[0m[1;39m,
      [0m[34;1m"created"[0m[1;39m: [0m[0;32m"1970-01-01T01:00:00+01:00"[0m[1;39m,
      [0m[34;1m"container_config"[0m[1;39m: [0m[1;39m{
        [0m[34;1m"Hostname"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"Domainname"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"User"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"AttachStdin"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"AttachStdout"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"AttachStderr"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"Tty"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"OpenStdin"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"StdinOnce"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"Env"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"Cmd"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"Image"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"Volumes"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"WorkingDir"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"Entrypoint"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"OnBuild"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"Labels"[0m[1;39m: [0m[1;30mnull[0m[1;39m
      [1;39m}[0m[1;39m,
      [0m[34;1m"os"[0m[1;39m: [0m[0;32m"linux"[0m[1;39m
    [1;39m}[0m
    === VERSION
    1.0
    
    === Tarball content
    total 36
    drwxrwxr-x  9 scoulomb scoulomb 4096 août  16 14:43 [0m[01;34m.[0m/
    drwxrwxr-x 11 scoulomb scoulomb 4096 août  16 14:43 [01;34m..[0m/
    drwxr-xr-x  2 scoulomb scoulomb 4096 juil. 12 04:48 [01;34mbin[0m/
    drwxr-xr-x 13 scoulomb scoulomb 4096 juil. 12 04:48 [01;34metc[0m/
    drwxr-xr-x  3 scoulomb scoulomb 4096 juil. 11 02:00 [01;34mlib[0m/
    drwxr-xr-x  2 scoulomb scoulomb 4096 juil. 12 04:48 [01;34msbin[0m/
    drwxrwxr-x  2 scoulomb scoulomb 4096 juil. 12 04:48 [01;34mtmp[0m/
    drwxr-xr-x  6 scoulomb scoulomb 4096 juil. 11 02:00 [01;34musr[0m/
    drwxr-xr-x  5 scoulomb scoulomb 4096 juil. 11 02:00 [01;34mvar[0m/
    ========================================================================================================
    == Showing layer e6be1d18b1e08a70a496a691e5aba4a0c5d5999db6a155af14ad222232e8be67 with index -10
    === json
    [1;39m{
      [0m[34;1m"id"[0m[1;39m: [0m[0;32m"e6be1d18b1e08a70a496a691e5aba4a0c5d5999db6a155af14ad222232e8be67"[0m[1;39m,
      [0m[34;1m"parent"[0m[1;39m: [0m[0;32m"aa93f3a87b7fa38394c5550145bdc9debf3915b860ea509444df8eb5ccd58a72"[0m[1;39m,
      [0m[34;1m"created"[0m[1;39m: [0m[0;32m"1970-01-01T01:00:00+01:00"[0m[1;39m,
      [0m[34;1m"container_config"[0m[1;39m: [0m[1;39m{
        [0m[34;1m"Hostname"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"Domainname"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"User"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"AttachStdin"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"AttachStdout"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"AttachStderr"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"Tty"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"OpenStdin"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"StdinOnce"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"Env"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"Cmd"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"Image"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"Volumes"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"WorkingDir"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"Entrypoint"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"OnBuild"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"Labels"[0m[1;39m: [0m[1;30mnull[0m[1;39m
      [1;39m}[0m[1;39m,
      [0m[34;1m"os"[0m[1;39m: [0m[0;32m"linux"[0m[1;39m
    [1;39m}[0m
    === VERSION
    1.0
    
    === Tarball content
    total 28
    drwxrwxr-x  7 scoulomb scoulomb 4096 août  16 14:43 [0m[01;34m.[0m/
    drwxrwxr-x 12 scoulomb scoulomb 4096 août  16 14:43 [01;34m..[0m/
    drwxr-xr-x  6 scoulomb scoulomb 4096 juil. 12 04:48 [01;34metc[0m/
    drwxr-xr-x  3 scoulomb scoulomb 4096 juil. 11 02:00 [01;34mlib[0m/
    drwxrwxr-x  2 scoulomb scoulomb 4096 juil. 12 04:48 [01;34mtmp[0m/
    drwxr-xr-x  6 scoulomb scoulomb 4096 juil. 11 02:00 [01;34musr[0m/
    drwxr-xr-x  5 scoulomb scoulomb 4096 juil. 11 02:00 [01;34mvar[0m/
    ========================================================================================================
    == Showing layer aa93f3a87b7fa38394c5550145bdc9debf3915b860ea509444df8eb5ccd58a72 with index -11
    === json
    [1;39m{
      [0m[34;1m"id"[0m[1;39m: [0m[0;32m"aa93f3a87b7fa38394c5550145bdc9debf3915b860ea509444df8eb5ccd58a72"[0m[1;39m,
      [0m[34;1m"parent"[0m[1;39m: [0m[0;32m"300b272b0214adc3c331f206bb0b863fdbfac74276ebb51412eca4b2ae5ffae9"[0m[1;39m,
      [0m[34;1m"created"[0m[1;39m: [0m[0;32m"1970-01-01T01:00:00+01:00"[0m[1;39m,
      [0m[34;1m"container_config"[0m[1;39m: [0m[1;39m{
        [0m[34;1m"Hostname"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"Domainname"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"User"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"AttachStdin"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"AttachStdout"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"AttachStderr"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"Tty"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"OpenStdin"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"StdinOnce"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"Env"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"Cmd"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"Image"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"Volumes"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"WorkingDir"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"Entrypoint"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"OnBuild"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"Labels"[0m[1;39m: [0m[1;30mnull[0m[1;39m
      [1;39m}[0m[1;39m,
      [0m[34;1m"os"[0m[1;39m: [0m[0;32m"linux"[0m[1;39m
    [1;39m}[0m
    === VERSION
    1.0
    
    === Tarball content
    total 24
    drwxrwxr-x  6 scoulomb scoulomb 4096 août  16 14:43 [0m[01;34m.[0m/
    drwxrwxr-x 13 scoulomb scoulomb 4096 août  16 14:43 [01;34m..[0m/
    drwxr-xr-x  4 scoulomb scoulomb 4096 juil. 12 04:48 [01;34metc[0m/
    drwxrwxr-x  2 scoulomb scoulomb 4096 juil. 12 04:48 [01;34mtmp[0m/
    drwxr-xr-x  7 scoulomb scoulomb 4096 juil. 11 02:00 [01;34musr[0m/
    drwxr-xr-x  5 scoulomb scoulomb 4096 juil. 11 02:00 [01;34mvar[0m/
    ========================================================================================================
    == Showing layer 300b272b0214adc3c331f206bb0b863fdbfac74276ebb51412eca4b2ae5ffae9 with index -12
    === json
    [1;39m{
      [0m[34;1m"id"[0m[1;39m: [0m[0;32m"300b272b0214adc3c331f206bb0b863fdbfac74276ebb51412eca4b2ae5ffae9"[0m[1;39m,
      [0m[34;1m"created"[0m[1;39m: [0m[0;32m"1970-01-01T01:00:00+01:00"[0m[1;39m,
      [0m[34;1m"container_config"[0m[1;39m: [0m[1;39m{
        [0m[34;1m"Hostname"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"Domainname"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"User"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"AttachStdin"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"AttachStdout"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"AttachStderr"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"Tty"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"OpenStdin"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"StdinOnce"[0m[1;39m: [0m[0;39mfalse[0m[1;39m,
        [0m[34;1m"Env"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"Cmd"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"Image"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"Volumes"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"WorkingDir"[0m[1;39m: [0m[0;32m""[0m[1;39m,
        [0m[34;1m"Entrypoint"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"OnBuild"[0m[1;39m: [0m[1;30mnull[0m[1;39m,
        [0m[34;1m"Labels"[0m[1;39m: [0m[1;30mnull[0m[1;39m
      [1;39m}[0m[1;39m,
      [0m[34;1m"os"[0m[1;39m: [0m[0;32m"linux"[0m[1;39m
    [1;39m}[0m
    === VERSION
    1.0
    
    === Tarball content
    total 84
    drwxrwxr-x 21 scoulomb scoulomb 4096 août  16 14:43 [0m[01;34m.[0m/
    drwxrwxr-x 14 scoulomb scoulomb 4096 août  16 14:43 [01;34m..[0m/
    drwxr-xr-x  2 scoulomb scoulomb 4096 juil. 11 02:00 [01;34mbin[0m/
    drwxr-xr-x  2 scoulomb scoulomb 4096 juin  30 23:35 [01;34mboot[0m/
    drwxr-xr-x  2 scoulomb scoulomb 4096 juil. 11 02:00 [01;34mdev[0m/
    drwxr-xr-x 30 scoulomb scoulomb 4096 juil. 11 02:00 [01;34metc[0m/
    drwxr-xr-x  2 scoulomb scoulomb 4096 juin  30 23:35 [01;34mhome[0m/
    drwxr-xr-x  8 scoulomb scoulomb 4096 juil. 11 02:00 [01;34mlib[0m/
    drwxr-xr-x  2 scoulomb scoulomb 4096 juil. 11 02:00 [01;34mlib64[0m/
    drwxr-xr-x  2 scoulomb scoulomb 4096 juil. 11 02:00 [01;34mmedia[0m/
    drwxr-xr-x  2 scoulomb scoulomb 4096 juil. 11 02:00 [01;34mmnt[0m/
    drwxr-xr-x  2 scoulomb scoulomb 4096 juil. 11 02:00 [01;34mopt[0m/
    drwxr-xr-x  2 scoulomb scoulomb 4096 juin  30 23:35 [01;34mproc[0m/
    drwx------  2 scoulomb scoulomb 4096 juil. 11 02:00 [01;34mroot[0m/
    drwxr-xr-x  3 scoulomb scoulomb 4096 juil. 11 02:00 [01;34mrun[0m/
    drwxr-xr-x  2 scoulomb scoulomb 4096 juil. 11 02:00 [01;34msbin[0m/
    drwxr-xr-x  2 scoulomb scoulomb 4096 juil. 11 02:00 [01;34msrv[0m/
    drwxr-xr-x  2 scoulomb scoulomb 4096 juin  30 23:35 [01;34msys[0m/
    drwxrwxr-x  2 scoulomb scoulomb 4096 juil. 11 02:00 [01;34mtmp[0m/
    drwxr-xr-x 11 scoulomb scoulomb 4096 juil. 11 02:00 [01;34musr[0m/
    drwxr-xr-x 11 scoulomb scoulomb 4096 juil. 11 02:00 [01;34mvar[0m/
    ========================================================================================================
    == Showing layer null with index -13
    === json
    cat: /home/scoulomb/tmp_image_format/toto_tar_uncompress/null/json: No such file or directory
    === VERSION
    cat: /home/scoulomb/tmp_image_format/toto_tar_uncompress/null/VERSION: No such file or directory
    
    
    === Tarball content
    tar: /home/scoulomb/tmp_image_format/toto_tar_uncompress/null/layer.tar: Cannot open: No such file or directory
    tar: Error is not recoverable: exiting now
    total 8
    drwxrwxr-x  2 scoulomb scoulomb 4096 août  16 14:43 [0m[01;34m.[0m/
    drwxrwxr-x 15 scoulomb scoulomb 4096 août  16 14:43 [01;34m..[0m/
    [?2004h



## Observations and take-away

- We have alayer per command (RUN, COPY, ADD) and not a layer per dockerfile
This is specific to docker, some other images building tool may have a diffrent behavior
For example: https://nixos.org/guides/building-and-running-docker-images.html

- Each layer reflect a state of file system.
Note the `.wh.toto_rm.txt`.
See docker without: https://github.com/moby/moby/blob/master/image/spec/v1.md#creating-an-image-filesystem-changeset






- Env var are added in last layer (created by Docker)


```bash
export LAYER_INDEX=-1
LAYER=$(jq --raw-output ".[0].Layers[$LAYER_INDEX]"  ~/tmp_image_format/toto_tar_uncompress/manifest.json | sed 's/\/layer.tar//g')
cat  ~/tmp_image_format/toto_tar_uncompress/$LAYER/json  | jq .container_config.Env
```

    [1;39m[[?2004l[?2004l
      [0;32m"PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"[0m[1;39m,
      [0;32m"LANG=C.UTF-8"[0m[1;39m,
      [0;32m"GPG_KEY=A035C8C19219BA821ECEA86B64E628F8D684696D"[0m[1;39m,
      [0;32m"PYTHON_VERSION=3.10.5"[0m[1;39m,
      [0;32m"PYTHON_PIP_VERSION=22.0.4"[0m[1;39m,
      [0;32m"PYTHON_SETUPTOOLS_VERSION=58.1.0"[0m[1;39m,
      [0;32m"PYTHON_GET_PIP_URL=https://github.com/pypa/get-pip/raw/6ce3639da143c5d79b44f94b04080abf2531fd6e/public/get-pip.py"[0m[1;39m,
      [0;32m"PYTHON_GET_PIP_SHA256=ba3ab8267d91fd41c58dbce08f76db99f747f716d85ce1865813842bb035524d"[0m[1;39m,
      [0;32m"tutu=toto"[0m[1;39m
    [1;39m][0m
    [?2004h



- Docker image are arhcitecture and OS specific (other layer do not mention archi in metadata, but I assume there is one). Cf [what-is-docker](./what-is-docker.md)


```bash
cat  ~/tmp_image_format/toto_tar_uncompress/$LAYER/json  | jq .architecture
cat  ~/tmp_image_format/toto_tar_uncompress/$LAYER/json  | jq .os
```

    [0;32m"amd64"[0m
    [0;32m"linux"[0m
    [?2004h



From observation we can start giving a definition to Docker [see next section](./what-is-docker.md).

<!-- sha seems consistent across rebuild,
 export via rigth clik file explo downalod and markdown export -->

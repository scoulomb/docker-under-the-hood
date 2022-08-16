## Image

Related to Docker images under the hood
  - [Docker image deep dive](./docker-image-deep-dive.md)
  - [Extended lab with Jupyter](./docker-image-deep-dive-extended-lab-with-jupyter/image-format-explo.ipynb) [setup](https://github.com/scoulomb/misc-notes/tree/master/Jupyter)

### Definition
It's a tarball containing:

- Metadata (json files: image name, env variables, command, entry-point, architecture, etc.)
- Directories and files

Each layer is stored as a different tarball.
The first layer contains the main filesystem.
Each subsequent layer contains the diff (what was added/removed).

See [investigation](./docker-image-deep-dive.md)

Add: file is added in the correct path;
Remove: see `.wh` extension

Limitation: a given image contains binaries, and therefore only works for a
specific CPU architecture (see metadata).

Corollary: the JVM is still useful: it will still compile the bytecode to
machine code on the fly, no matter the CPU architecture.

Limitation: the os is specified, and so a Linux image can only run on a Linux host,
and same for all other OSs (or in a VM/VM-like: wsl is a Linux VM for Windows
allowing that, there is a similar VM on MacOS to run Linux images).

WSL is [not exactly a traditional VM](https://docs.microsoft.com/en-us/windows/wsl/compare-versions).

Some images are for Windows (ex: Windows 11 docker images): https://hub.docker.com/_/microsoft-windows-base-os-images
Windows can use Hyper-V or not (if the windows version of the image is different
from the one of the host).


### Consequences
When compiling a C++ program, the output can only run if:
- the CPU architecture is the same;
- the libc is the same (the libc depends on the OS. Ex: Linux: libc, glibc, muslc (Alpine), Windows: libvs2021, MacOS: ??)

When packaging a program written in C++ inside an image,
the libc version is assured to be the needed one.

When packaging a JVM jar/war, it can only be run if:
- a JVM has been compiled for the OS and CPU architecture targetted.

You can download the JVM for a given OS and CPU arch:
https://www.azul.com/downloads/?version=java-17-lts&os=linux&package=jdk

=> the end-user doesn't have to know/compile the program for any architecture.

(JVM JIT will compile the classes on the fly for you):
JVM languages are interpreted and compiled.

=> that's why there is a small warm-up of the JVM.

If you deliver a jar/war, only 1 is needed for all CPU architectures and OSs.

Images negate this advantage.

Image fix all the environment: _all_ files (including dynamic libraries),
_all_ env. variables, etc.

## Container

Related to [Container-under-the-hood-link-snat-dnat](container-under-the-hood-link-snat-dnat.md)

### Definition
It's filesystem running in a namespace (isolation: filesystem, network, time, etc.)
with some cgroups (Resources isolation) limits applied.

- namespaces: https://en.wikipedia.org/wiki/Linux_namespaces
- cgroups: https://en.wikipedia.org/wiki/Cgroups

Note: cgroups _can_ be seen as a namespace.

The cgroup limits are not part of the image, and are decided when starting the
container (eg: kubernetes requests/limits).

The container runs the binary only sharing the host's Linux kernel.

This is handled by a container engine: https://github.com/scoulomb/myk8s/blob/master/container-engine/container-engine.md.

It's been standardized: https://opencontainers.org/

### Consequences
- The container engine has to be trusted not to tamper with the data of the image.
- A container _does not have_ to be come from a multi-layered image (can be a single fat layer).
- Anyone can implement a container engine as long as it matches the standard.

## Container vs VM?
Containers all share the same Linux Kernel of the host/node on which they run.

VMs use their own kernel/OS.

VM use an hypervisor to abstract the physical host.

Containers _can_ run on a host on bare-metal (in reality, they might still run on a VM).

Schema:

![Containers vs VM showing docker engine is running on the side](./media/containers-vs-virtual-machines.jpg)

Note: most schema show docker as a layer between the containers and the host, but this is incorrect.
(Proof: `ps aux` shows the actual running process like any other one on a node).


## Docker
Docker is a cli.

### Images
1. Docker defined _one_ way to build an image (Dockerfile)
2. Docker enforces the immutability of images
3. Images are split into layers that can be reused between images (thanks to immutability)
4. Docker created a central repository of images (dockerhub)

### Containers
1. Run images from the central repository with a simple cli
2. Specify the cgroups limits form the same cli
3. Some niceties: docker ps, docker ls, etc.

### What Docker missed
Orchestration of containers (docker-compose tried, but didn't win).

Kubernetes came and won:

> Kubernetes is system for automating deployment, scaling, and management of containerized applications.

Source: https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/

Kubernetes says that it is _not_ a PaaS.

Openshift takes Kubernetes, and makes it a Paas: https://access.redhat.com/documentation/en-us/openshift_container_platform/4.10/html/getting_started/openshift-overview

Kubernetes is tool that you can run to offer a PaaS to someone else.

The list of features that defines a PaaS is a moving target.

<!-- for multiarchi, see also

- https://itnext.io/building-multi-cpu-architecture-docker-images-for-arm-and-x86-1-the-basics-2fa97869a99b
- https://docs.docker.com/desktop/multi-arch/ 

--> 

## Other definition 

<!-- readme container puis image, in summary here image then container, makes more sense, wikipedia same order as readme, docker website as summary -->

### Docker website itself

https://www.docker.com/resources/what-container/

> A container is a standard unit of software that packages up code and all its dependencies so the application runs quickly and reliably from one computing environment to another.

#### [website:Image](#image) 

> A **Docker container image** is a lightweight, standalone, executable package of software that includes everything needed to run an application: code, runtime, system tools, system libraries and settings.

#### [website:Container](#container)

> **Container images** become **containers at runtime** and in the case of Docker containers – **images become containers when they run on Docker Engine.**

> Available for both Linux and Windows-based applications, containerized software will always run the same, regardless of the infrastructure. Containers isolate software from its environment and ensure that it works uniformly despite differences for instance between development and staging.

#### [website:Docker](#docker)

> Docker containers that run on Docker Engine:

> - Standard: Docker created the industry standard for containers, so they could be portable anywhere
> - Lightweight: Containers share the machine’s OS system kernel and therefore do not require an OS per application, driving higher server efficiencies and reducing server and licensing costs
> - Secure: Applications are safer in containers and Docker provides the strongest default isolation capabilities in the industry


#### [website:Container vs VM?](#container-vs-vm)


**CONTAINERS**

> Containers(*) are an abstraction at the app layer that packages code and dependencies together. Multiple containers can run on the same machine and share the OS kernel with other containers, each running as isolated processes in user space. Containers take up less space than VMs (container images are typically tens of MBs in size), can handle more applications and require fewer VMs and Operating systems.

(*) here whole ecosystem image + container

**VIRTUAL MACHINES**

> Virtual machines (VMs) are an abstraction of physical hardware turning one server into many servers. The hypervisor allows multiple VMs to run on a single machine. Each VM includes a full copy of an operating system, the application, necessary binaries and libraries – taking up tens of GBs. VMs can also be slow to boot.

> **Containers and VMs used together provide a great deal of flexibility in deploying and managing app**

### Wikipedia (and completed)

https://en.wikipedia.org/wiki/Docker_(software)

#### [Wiki:Image](#image)

> A Docker image is a read-only template used to build containers. Images are used to store and ship applications.

It enables to package an application with dependencies.

<!-- do not confuse with Dockerfile -->

#### [Wiki:Container](#container)

> A Docker container is a standardized, encapsulated environment that runs applications. A container is managed using the Docker API or CLI.

It is using namespace and cgroup to perfrom encaspulation. A **Container images** become **containers at runtime**.

## Key take-away

- [Completed Wikipedia docker defintion](#wikipedia-and-completed) definition 
- [Docker website container vs VM](#websitecontainer-vs-vmcontainer-vs-vm)
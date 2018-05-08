# docker-topo
Docker network topology builder

[![Build Status](https://travis-ci.org/networkop/arista-ceos-topo.svg?branch=dev)](https://travis-ci.org/networkop/arista-ceos-topo)

# TODO

* Write more tests

# Installation

````bash
pip install git+https://github.com/networkop/arista-ceos-topo.git@dev
````

# Usage

```bash
# docker-topo -h
usage: docker-topo [-h] [-d] [--create | --destroy] topology

Tool to create cEOS topologies

positional arguments:
  topology     Topology file

optional arguments:
  -h, --help   show this help message and exit
  -d, --debug  Enable Debug
  --create     Create topology
  --destroy    Destroy topology
```

# Topology file

Topology file is a YAML file describing how docker containers are to be interconnected.
This information is stored in the `links` variable which 
contains a list of links, each described by a unique set of connected interfaces. 
Currently, two versions of link definitions are supported.

## Topology file v1
Each link in a `links` array is itself a list, identifying all connected devices:
```yaml
links:
  - ["Device-A:Interface-1", "Device-B:Interface-2"]
  - ["Device-A:Interface-2", "Device-B:Interface-2", "cvp-1"]
  - ["Device-A:Interface-3", "Host-1:Interface-1", "host-2", "host3:Interface-2:192.168.0.10/24"]
```
Each connected device, or link endpoint, is encoded as "DeviceName:InterfaceName:IP" with the following constraints:

* **DeviceName** determines which docker image is going to be used by (case-insensitive) matching of the following strings:
  * **host** - alpine-host image is going to be used
  * **cvp** - cvp image is going to be used
  * For anything else Arista cEOS image will be used 
* **InterfaceName** does not have to match the actual link name inside the container, only the sequence number has to match. (Internally all links are sorted alphabetically before being attached). Also see notes for v2 **veth** driver.
* **IP** - Optional parameter that works **ONLY** for alpine-host devices. This will attempt to configure a provided IP address inside a container.

## Topology file v2
Each link in a `links` array is a dictionary in the following format:
```yaml
links:
  - endpoints:
      - "Device-A:Interface-2" 
      - "Device-B:Interface-1"
  - driver: macvlan
    driver_opts: 
      parent: wlp58s0
    endpoints: ["Device-A:Interface-1", "Device-B:Interface-2"]
```
Each link supports the following objects:

* **endpoints** - the only mandatory element, contains a list of endpoints to be connected to a link. The endpoint definition is similar to the version 1, described above
* **driver** - defines the link driver to be used. Currently supported drivers are **veth, bridge, macvlan**. When driver is not specified, default **bridge** driver is used. The following limitations apply:
  * **macvlan** driver will require a mandatory **driver_opts** object described below
  * **veth** is mutually exclusive with any other driver. This driver is talking to netlink and making changse to namespaces; make sure you always use `sudo` when building **veth**-based topologies
* **driver_opts** - optional object containing driver options as required by Docker's libnetwork. Currently only used for macvlan's parent interface definition


## (Optional) Global variables
Along with the mandatory `link` array, there are a number of options that can be specified to override some of the default settings. Below are the list of options with their default values:

```yaml
VERSION: 1  # Topology file version. Accepts [1|2]
CEOS_IMAGE: ceos:latest # cEOS docker image name
CONF_DIR: './config' # Config directory to store cEOS startup configuration files
PUBLISH_BASE: 8000 # Publish cEOS ports starting from this number
OOB_PREFIX: '192.168.100.0/24' # Only used when link contains CVP. This prefix is assinged to CVP's eth1
driver: None
```

All of the capitalised global variables can also be provided as environment variables with the following priority:

1. Global variables defined in a topology file
2. Global variables from environment variables
3. Defaults

The final **driver** variable can be used to specify the version 2 link driver for **ALL** links at once. This is useful for **veth** type drivers:

```yaml
VERSION: 2
driver: veth
links:
  - endpoints: ["host1:eth1", "host2:eth1"]
```

> Note: For **veth** link driver all interfaces must match the ones you expect to see inside a container. So if you expect to connect your link to DeviceA interface eth0, the endpoint definition should be "DeviceA:eth0"


There should be several examples in the `./topo-extra-files/examples` directory


# Example 1 - Creating a 2-node topology interconnected directly with veth links (without config)

```text
+------+             +------+
|      |et1+-----+et2|      |
|cEOS 1|             |cEOS 2|
|      |et2+-----+et1|      |
+------+             +------+
```

```bash
sudo docker-topo --create topo-extra-files/examples/v2/2-node.yml
```

# Example 2 - Creating a 3-node topology using the default docker bridge driver (with config)
```text
+------+             +------+
|cEOS 1|et1+-----+et2|cEOS 2|
+------+             +------+
   et2                  et1
    +                    +
    |      +------+      |
    +--+et1|cEOS 3|et2+--+
           +------+

```

```bash
mkdir config
echo "hostname cEOS-1" > ./config/3-node_cEOS-1
echo "hostname cEOS-2" > ./config/3-node_cEOS-2
echo "hostname cEOS-3" > ./config/3-node_cEOS-3
docker-topo --create topo-extra-files/examples/3-node.yml
```

# List and connect to devices

```bash
# docker ps -a 
CONTAINER ID        IMAGE               COMMAND                  CREATED              STATUS                     PORTS                   NAMES
2315373f8741        ceosimage:latest    "/sbin/init"             About a minute ago   Up About a minute          0.0.0.0:9002->443/tcp   3-node_cEOS-3
e427def01f3a        ceosimage:latest    "/sbin/init"             About a minute ago   Up About a minute          0.0.0.0:9001->443/tcp   3-node_cEOS-2
f1a2ac8a904f        ceosimage:latest    "/sbin/init"             About a minute ago   Up About a minute          0.0.0.0:9000->443/tcp   3-node_cEOS-1


# docker exec -it 3-node_cEOS-1 Cli
cEOS-1>
```

# Destroy a topology

```bash
docker-topo --destroy topo-extra-files/examples/3-node.yml
```

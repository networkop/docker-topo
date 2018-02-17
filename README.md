# arista-ceos-topo
Arista cEOS topology builder

# Installation

````bash
pip install git+https://github.com/networkop/arista-ceos-topo.git
````

# Usage

```bash
# ceos-topo -h
usage: ceos-topo [-h] [-d] [--create | --destroy] topology

Tool to create cEOS topologies

positional arguments:
  topology     Topology file

optional arguments:
  -h, --help   show this help message and exit
  -d, --debug  Enable Debug
  --create     Create topology
  --destroy    Destroy topology
```

Topology file is a YAML file describing how cEOS are to be interconnected.
There should be three examples in the `./examples` directory

# (Optional) Override default variables
There are three global variables used by the script 
which can be overridden in the topology files:

* PREFIX - unique label assigned to all docker containers and links for a single topology.
  Used as a filter during the cleanup process.
* CONF_DIR - path to the config directory if/when configuration files are supplied
* CEOS_IMAGE - Name of the cEOS image to use

If none of the variables are found in the topology file, the following defaults will be used:

* CONF_DIR = './config'
* PREFIX = 'CEOS-LAB'
* CEOS_IMAGE = 'ceos:latest'

# Example 1 - Creating a 2-node topology (no config)

```text
+------+             +------+
|      |et1+-----+et2|      |
|cEOS 1|             |cEOS 2|
|      |et2+-----+et1|      |
+------+             +------+
```

```bash
ceos-topo --create examples/2-node.yml
```

# Example 2 - Creating a 3-node topology (with config)
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
echo "hostname Device-A" > ./config/Device-A
echo "hostname Device-B" > ./config/Device-B
echo "hostname Device-C" > ./config/Device-C
ceos-topo --create examples/3-node.yml
```

# List and connect to devices

```bash
# docker ps -a 
CONTAINER ID        IMAGE               COMMAND             CREATED             STATUS              PORTS               NAMES
3d61fb999756        veos:latest         "/sbin/init"        2 minutes ago       Up 2 minutes                            Device-B
4b5743e64e5e        veos:latest         "/sbin/init"        2 minutes ago       Up 2 minutes                            Device-A

# docker exec -it Device-A Cli
localhost>
```

# Destroy a topology

```bash
ceos-topo --destroy examples/2-node.yml
```

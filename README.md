# arista-ceos-topo
Arista cEOS topology builder

# Installation

````bash
pip install git+https://github.com/networkop/arista-ceos-topo.git
````

# 2-node topology setup (no config)
```bash
ceos-topo --create examples/2-node.yml
```

# 3-node topology setup (with config)
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

# Destroy topology

```bash
ceos-topo --destroy examples/2-node.yml
```

# Script help

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
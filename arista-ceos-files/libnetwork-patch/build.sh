#!/bin/bash

# Installing dependencies
yum install -y git iptables make "Development Tools" yum-utils device-mapper-persistent-data lvm2 patch
yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

yum install docker-ce -y

# Cloning main docker repo
git clone --depth=1 https://github.com/docker/docker.git
cd docker

# Just using VNDR didn't work for me
# go get github.com/LK4D4/vndr
# vndr github.com/docker/libnetwork d047825d4d156bc4cf01bfe410cb61b3bc33f572 https://github.com/cziebuhr/libnetwork.git
# So I'm doing the same thing manually

git clone https://github.com/cziebuhr/libnetwork.git temp
cd temp
git checkout d047825d4d156bc4cf01bfe410cb61b3bc33f572
cp controller.go endpoint.go sandbox.go sandbox_store.go ../vendor/github.com/docker/libnetwork/

# Finally some minor path of the patch (not sure why this was needed)
```bash
cat << EOF > ./ipam.patch
224c224
<         if err = initIPAMDrivers(drvRegistry, nil, c.getStore(datastore.GlobalScope)); err != nil {
---
>       if err = initIPAMDrivers(drvRegistry, nil, c.getStore(datastore.GlobalScope), c.cfg.Daemon.DefaultAddressPool); err != nil {
EOF

patch ./controller.go ./ipam.patch
```

# Build docker
# This may require up to 100G of free disk space
make build
make binary

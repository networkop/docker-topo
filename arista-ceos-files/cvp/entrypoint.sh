#!/bin/bash

IPADDR=${1:-172.17.0.253}
NETMASK=${2:-255.255.255.0}
GW=${3:-172.17.0.1}

# Fill in the real IP values to be used by CVP VM
sed -i "s/IPADDR/${IPADDR}/" /tmp/answers.yaml
sed -i "s/NETMASK/${IPADDR}/" /tmp/answers.yaml
sed -i "s/GATEWAY/${GW}/" /tmp/answers.yaml

# Create bridge for VMs
/tmp/createNwBridges.py --device-bridge virbr0 --device-nic eth0 --swap-device-nic-ip --force -g $GW

# Start libvirt services
/usr/sbin/libvirtd &
/usr/sbin/virtlogd &

# Wait for 10 seconds for libvirt sockets to be created
TIMEOUT=$((SECONDS+10))
while [ $SECONDS -lt $TIMEOUT ]; do
    if [ -S /var/run/libvirt/libvirt-sock ]; then
       break;
    fi
done

# Create a VM
virsh define result.xml
virsh start cvp

# Sleep and wait for the kill
trap : TERM INT; sleep infinity & wait

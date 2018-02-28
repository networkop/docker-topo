#!/bin/bash

# Create bridge for VMs
/tmp/createNwBridges.py --device-bridge virbr0 --device-nic eth0 --swap-device-nic-ip --force -g 172.17.0.1
/tmp/createNwBridges.py --device-bridge virbr1 --device-nic eth1 --swap-device-nic-ip --force

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

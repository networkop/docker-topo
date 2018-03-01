#!/bin/bash

IPADDR=${1:-172.17.0.253}
NETMASK=${2:-255.255.255.0}
GW=${3:-172.17.0.1}

# Steal the dhcp IP off the main interface
IPADDR=$(ip route get 8.8.8.8 | awk 'NR==1 {print $NF}')

# unset the stolen IP off the main interface
ip addr flush dev eth0

# Fill in the real IP values to be used by CVP VM
sed -i "s/IPADDR/${IPADDR}/" /tmp/answers.yaml
sed -i "s/NETMASK/${NETMASK}/" /tmp/answers.yaml
sed -i "s/GATEWAY/${GW}/" /tmp/answers.yaml

# Create bridge for VMs
# /tmp/createNwBridges.py --device-bridge virbr0 --device-nic eth0 --force
brctl addbr virbr0
brctl addif virbr0 eth0
ip link set dev virbr0 up

# Generate ISO
/tmp/geniso.py  -y /tmp/answers.yaml -p cvpadmin -o /tmp/

# Generate libvirt XML
/tmp/generateXmlForKvm.py -n cvp \
--device-bridge virbr0 -i /tmp/cvxTemplate.xml -o result.xml \
-x /tmp/disk1.qcow2 -y /tmp/disk2.qcow2 -c /tmp/node1-cvp.iso \
-b 10240 -p 2 \
-e /usr/libexec/qemu-kvm

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

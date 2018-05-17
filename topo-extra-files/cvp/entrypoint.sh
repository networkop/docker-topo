#!/bin/bash

IPADDR_2=$1
NETMASK_2=$2

# Steal the DHCP IP off the first 2 interfaces
IPADDR_1=$(ip route get 8.8.8.8 | awk 'NR==1 {print $7}')
NETMASK_1=$(ifconfig | grep $IPADDR_1 | awk 'NR==1 {print $4}')
GW=$(ip route get 8.8.8.8 | awk 'NR==1 {print $3}')

#IPADDR_2=$(ifconfig eth1 | awk 'NR==2 {print $2}')
#NETMASK_2=$(ifconfig eth1 | awk 'NR==2 {print $4}')

# unset the stolen IP off the first 2 interfaces
ip addr flush dev eth0
#ip addr flush dev eth1

# disable offload to prevent TCP checksum corruption
ethtool -K eth1 rx off > /dev/null 2>&1
ethtool -K eth1 tx off > /dev/null 2>&1

# Fill in the IP values to be used by CVP VM
sed -i "s/IPADDR_1/${IPADDR_1}/" /tmp/answers.yaml
sed -i "s/NETMASK_1/${NETMASK_1}/" /tmp/answers.yaml
sed -i "s/GATEWAY/${GW}/" /tmp/answers.yaml

sed -i "s/IPADDR_2/${IPADDR_2}/" /tmp/answers.yaml
sed -i "s/NETMASK_2/${NETMASK_2}/" /tmp/answers.yaml

# Create bridge for VMs
# /tmp/createNwBridges.py --device-bridge virbr0 --device-nic eth0 --force
brctl addbr virbr0
brctl addif virbr0 eth0
ip link set dev virbr0 up

# Same for the second interface
brctl addbr virbr1
brctl addif virbr1 eth1
ip link set dev virbr1 up

# Generate ISO
/tmp/geniso.py  -y /tmp/answers.yaml -p cvpadmin -o /tmp/

# Generate libvirt XML
/tmp/generateXmlForKvm.py -n cvp \
--device-bridge virbr0 --cluster-bridge virbr1 -i /tmp/cvxTemplate.xml -o result.xml \
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

#!/bin/bash

# Number of interfaces (optional argument)
INT_NUM=$1

# Default is 1 (only Management1 will be visible)
if [ -z "$INT_NUM" ]; then
  INT_NUM='1'
fi

INT_NUM=$((INT_NUM-1))

####################
# Creating bridges #
####################
BRIDGE=""
# Create the right number of bridges
for i in $(seq 0 $INT_NUM); do
  BRIDGE=$BRIDGE"brctl addbr virbr$i \n"
  BRIDGE=$BRIDGE"brctl addbr virbr$i eth$i \n"
  BRIDGE=$BRIDGE"ip link set dev virbr$i up \n"
done

echo $BRIDGE
eval $BRIDGE

#############################
# Starting libvirt services #
#############################
/usr/sbin/libvirtd &
/usr/sbin/virtlogd &

# Wait for 10 seconds for libvirt sockets to be created
TIMEOUT=$((SECONDS+10))
while [ $SECONDS -lt $TIMEOUT ]; do
    if [ -S /var/run/libvirt/libvirt-sock ]; then
       break;
    fi
done

################# 
# Creating a VM #
#################
VIRT_MAIN="virt-install \
  --connect qemu:///system \
  -n veos \
  -r 1536 \
  --vcpus 1 \
  --os-type=linux \
  --disk path=/var/lib/libvirt/images/veos.qcow2,bus=ide \
  --cdrom /var/lib/libvirt/images/aboot.iso \
  --graphics none \
  --console pty,target_type=serial"

VIRT_NET=""
for i in $(seq 0 $INT_NUM); do 
  VIRT_NET=$VIRT_NET" --network bridge=virbr$i,model=e1000"
done

VIRT_FULL=$VIRT_MAIN$VIRT_NET

echo $VIRT_FULL
eval $VIRT_FULL

# Sleep and wait for the kill
trap : TERM INT; sleep infinity & wait

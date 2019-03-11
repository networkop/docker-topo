#!/bin/bash

echo 'Sleeping to wait for all interfaces to be connected'
sleep 5

echo 'Making sure that character device /dev/kvm exists and setting the right permissions'
if [ ! -c /dev/kvm ]; then
  echo "Requirement not satisfied: /dev/kvm not present"
  exit 1
fi
chown root:kvm /dev/kvm
ls -la /dev/kvm

echo '############################'
echo '# Stealing the IP off eth0 #'
echo '############################'

HOSTNAME=$(hostname)
IPADDR=$(ip addr show eth0 | grep inet | awk 'NR==1 {print $2}')
GW=$(ip route get 8.8.8.8 | awk 'NR==1 {print $3}')
ip addr flush dev eth0
ip addr

echo '####################################'
echo '# Saving eth0 IP in startup-config #'
echo '####################################'

rm -f /tmp/management-config

cat << EOF > /tmp/management-config
!
interface Management1
   ip address $IPADDR
   no shutdown
   exit
!
ip route 0.0.0.0/0 $GW
!
EOF


cat /tmp/management-config >> /mnt/flash/startup-config
cat /mnt/flash/startup-config

INTFS=$(ls /sys/class/net/ | grep 'eth\|ens\|eno')

echo '####################'
echo '# Creating bridges #'
echo '####################'
BRIDGE=""
ip link add name bridge_name type bridge
for i in $INTFS; do
  BRIDGE=$BRIDGE"ip link add name br-$i type bridge;"
  BRIDGE=$BRIDGE"ip link set br-$i up;"
  BRIDGE=$BRIDGE"ip link set $i master br-$i;"
  BRIDGE=$BRIDGE"echo 16384 > /sys/class/net/br-$i/bridge/group_fwd_mask;"
  
done

echo -e $BRIDGE
eval $BRIDGE

echo '====='
bridge link
echo '====='
brctl show
echo '====='

echo '#############################'
echo '# Starting libvirt services #'
echo '#############################'

/usr/sbin/libvirtd &
/usr/sbin/virtlogd &

echo '# Wait for 10 seconds for libvirt sockets to be created'
TIMEOUT=$((SECONDS+10))
while [ $SECONDS -lt $TIMEOUT ]; do
    if [ -S /var/run/libvirt/libvirt-sock ]; then
       break;
    fi
done

echo '##########################'
echo '# Create a startup CDROM #'
echo '##########################'

HOSTNAME=$(hostname)
if [ ! -f /mnt/flash/startup-config ]; then
  echo "hostname $HOSTNAME" > /mnt/flash/startup-config
fi

genisoimage -J -r -o /var/lib/libvirt/images/cdrom.iso /mnt/flash/startup-config /mnt/flash/rc.eos

echo '#################'
echo '# Creating a VM #'
echo '#################'

VIRT_MAIN="virt-install \
  --connect qemu:///system \
  --autostart \
  -n veos \
  -r 2048 \
  --vcpus 1 \
  --os-type=linux \
  --disk path=/var/lib/libvirt/images/veos.qcow2,bus=ide \
  --disk path=/var/lib/libvirt/images/cdrom.iso,device=cdrom \
  --graphics none \
  --console pty,target_type=serial"

VIRT_NET=""
for i in $INTFS; do 
  VIRT_NET=$VIRT_NET" --network bridge=br-$i,model=e1000"
done

VIRT_FULL=$VIRT_MAIN$VIRT_NET

if virsh dominfo veos; then 
  echo 'VEOS VM already exists, destroying the old domain'
  virsh destroy veos
  virsh undefine veos
fi

echo $VIRT_FULL
eval $VIRT_FULL

echo "Management IP = $IPADDR"

# Sleep and wait for the kill
trap : TERM INT; sleep infinity & wait

#!/bin/bash

echo 'Sleeping to wait for all interfaces to be connected'
sleep 2

VMNAME=veos
RAM=2048
CPU=1

echo '#####################'
echo '# Checking /dev/kvm #'
echo '#####################'

echo 'Making sure that character device /dev/kvm exists and setting the right permissions'
if [ ! -c /dev/kvm ]; then
  echo "Requirement not satisfied: /dev/kvm not present"
  exit 1
fi
chown root:kvm /dev/kvm
ls -la /dev/kvm

echo '############################'
echo '# Preparing startup-config #'
echo '############################'

HOSTNAME=$(hostname)
IPADDR=10.0.0.15/24
GW=10.0.0.2

HOSTNAME=$(hostname)
if [ ! -f /mnt/flash/startup-config ]; then
  echo "hostname $HOSTNAME" > /mnt/flash/startup-config
fi

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

echo '#########################'
echo '# Setting up interfaces #'
echo '#########################'

INTFS=($(ls -1v /sys/class/net/ | grep 'eth\|ens\|eno'))

ADDR=()
for slot in `seq 3 19`; do
  for fn in `seq 0 7`; do
    ADDR+=("${slot}.${fn}");
  done;
done

if [ "${#INTFS[@]}" -gt "${#ADDR[@]}" ]; then
  echo "Maximum number of interfaces ${#ADDR} exceeded"
  return 1
fi

echo '== BEFORE =='
ip link
echo '== BEFORE =='

echo '#####################'
echo '# Creating macvtaps #'
echo '#####################'
for idx in "${!INTFS[@]}"; do
  intf="${INTFS[$idx]}"
  echo "Preparing interface ${intf}"
  if [ "${intf}" == "eth0" ]; then 
    continue
  fi
  NAME="macvtap${idx}"
  ip link add link $intf name $NAME type macvtap mode passthru
  ip link set $NAME up
  ip link set dev $NAME allmulticast on
  read MAJOR MINOR < <(cat /sys/devices/virtual/net/$NAME/tap*/dev | tr ':' ' ')
  mknod /dev/tap-$idx c ${MAJOR} ${MINOR}
done

echo '== AFTER =='
ip link
echo '== AFTER =='

echo '############################'
echo '# Creating a startup CDROM #'
echo '############################'

genisoimage -J -r -o /var/lib/libvirt/images/cdrom.iso /mnt/flash/startup-config /mnt/flash/rc.eos

echo '#################'
echo '# Creating a VM #'
echo '#################'

QEMU="/usr/libexec/qemu-kvm \
  -name $VMNAME \
  -machine pc \
  -enable-kvm \
  -m $RAM \
  -cpu host,level=9 \
  -smp $CPU,sockets=1,cores=1 \
  -display none \
  -nographic \
  -serial telnet:0.0.0.0:23,server,nowait \
  -monitor telnet:0.0.0.0:2323,server,nowait \
  -boot d \
  -drive file=/var/lib/libvirt/images/veos.qcow2,format=qcow2,if=ide \
  -drive file=/var/lib/libvirt/images/cdrom.iso,format=raw,media=cdrom,readonly"

echo '###################'
echo '# Generating NICs #'
echo '###################'

NICS=""
for idx in "${!INTFS[@]}"; do
  intf="${INTFS[$idx]}"
  addr="${ADDR[$idx]}"
  if [ "${intf}" == "eth0" ]; then 
    NICS=$NICS" -device virtio-net-pci,netdev=mgmt,addr=${addr},multifunction=on "
    NICS=$NICS" -netdev user,id=mgmt,net=10.0.0.0/24,hostfwd=tcp::22-:22 "
    continue
  fi
  name="macvtap${idx}"
  mac=$(cat /sys/class/net/$name/address)
  NICS=$NICS" -device virtio-net-pci,netdev=net${idx},mac=${mac},addr=${addr},multifunction=on "
  NICS=$NICS" -netdev tap,id=net${idx},fd=${idx} ${idx}<>/dev/tap-${idx} "
done

QEMU_FULL=$QEMU$NICS

echo $QEMU_FULL > startup
eval $QEMU_FULL &

iptables -t nat -A INPUT -j SNAT --to-source 10.0.0.2

echo "VM has started..."

# Sleep and wait for the kill
trap : TERM INT; sleep infinity & wait

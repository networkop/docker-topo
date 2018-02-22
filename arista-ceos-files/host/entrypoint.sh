#!/bin/sh

#################
# Parse arguments
#################

IP=$1
TMODE=$2

if [ -z "$IP" ]; then
  echo "IP address not set!"
  return 1
fi

if [ -z "$TMODE" ]; then
  TMODE='static'
fi
  

#######################
# Re-run script as sudo
#######################

if [ "$(id -u)" != "0" ]; then
  exec sudo "$0" "$@" 
fi

###############
# Enabling LLDP
###############

lldpad -d
for i in `ls /sys/class/net/ | grep 'eth\|ens\|eno'`
do
    lldptool set-lldp -i $i adminStatus=rxtx
    lldptool -T -i $i -V sysName enableTx=yes
    lldptool -T -i $i -V portDesc enableTx=yes
    lldptool -T -i $i -V sysDesc enableTx=yes
done

##################
# Enabling teaming
##################

teamd -v 

ip link set eth0 down
ip link set eth1 down

cat << EOF > /home/alpine/teamd-static.conf
{
 "device": "team0",
 "runner": {"name": "roundrobin"},
 "ports": {"eth0": {}, "eth1": {}}
}
EOF

cat << EOF > /home/alpine/teamd-lacp.conf
{
   "device": "team0",
   "runner": {
       "name": "lacp",
       "active": true,
       "fast_rate": true,
       "tx_hash": ["eth", "ipv4", "ipv6"]
   },
     "link_watch": {"name": "ethtool"},
     "ports": {"eth0": {}, "eth1": {}}
}
EOF

if [ "$TMODE" == 'lacp' ]; then
  TARG='/home/alpine/teamd-lacp.conf'
else
  TARG='/home/alpine/teamd-static.conf'
fi

teamd -d -f $TARG

ip link set team0 up

ip addr add $IP dev team0

#####################
# Enter sleeping loop
#####################

while sleep 3600; do :; done

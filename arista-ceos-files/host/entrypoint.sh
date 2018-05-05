#!/bin/sh


# Hardcoding LACP to none for now
# May need to revisit later
TMODE="none"
UPLINK='eth'

if [ -z "$TMODE" ]; then
  TMODE='none'
  
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

################
# Teaming setup
################

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
     "ports": {"eth1": {}, "eth2": {}}
}
EOF

cat << EOF > /home/alpine/teamd-static.conf
{
 "device": "team0",
 "runner": {"name": "roundrobin"},
 "ports": {"eth1": {}, "eth2": {}}
}
EOF

if [ "$TMODE" == 'lacp' ]; then
  TARG='/home/alpine/teamd-lacp.conf'
elif [ "$TMODE" == 'static' ]; then
  TARG='/home/alpine/teamd-static.conf'
fi

if [ "$TMODE" == 'lacp' ] || [ "$TMODE" == 'static' ]; then
  teamd -v
  ip link set eth1 down
  ip link set eth2 down
  teamd -d -f $TARG

  ip link set team0 up
  UPLINK="team"
fi

################
# IP addr setup
################

for i in `seq 1 $#`; do
  eval ip="\$$i"
  cmd1="ip flush dev $UPLINK$((i-1))"
  cmd2="ip addr add $ip dev $UPLINK$((i-1))"
  echo $cmd1
  echo $cmd2
  eval $cmd1
  eval $cmd2
done

#####################
# Enter sleeping loop
#####################

while sleep 3600; do :; done
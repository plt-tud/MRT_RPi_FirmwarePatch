#!/bin/bash
CONFIGFILE="../../etc/pltscripts.conf"

. $CONFIGFILE

function getDeviceInfo() {
  SERIAL=`awk '/Serial/ {SN=substr($0,index($0,":")+1); gsub(" ","",SN); print SN; exit}' /proc/cpuinfo`
  ETHMAC=`ip link show eth0   | awk '/ether/ {gsub(":",""); print toupper( substr($2,5,12) )}'`
  WLANMAC=`ip link show wlan0 | awk '/ether/ {gsub(":",""); print toupper( substr($2,5,12) )}'`
  
  DEVID="${ETHMAC}-${WLANMAC}"
  
  if [ -z $SERIAL ]; then
    SERIAL="000000"
  elif [ -z $DEVID ]; then
    DEVID="XXXXXXXX-YYYYYYYY"
  fi
}

function cmd_echo() {
  if [ $CFG_ENABLE_KEEPALIVE_CMD_ECHO -eq 1 ]; then
    wget -q "http://$GATEWAY:$CFG_KEEPALIVE_GATEWAY_PORT/registerdev.php?deviceId=$DEVID&serial=$SERIAL" -O "$TMPFILE"
  fi
}

function cmd_ping() {
  if [ -f $CFG_LEDTRIGGER ]; then
    echo "heartbeat" > $CFG_LEDTRIGGER
    sleep 7
    echo "none" > $CFG_LEDTRIGGER
  fi
}

function cmd_lock() {
  cat $CONFIGFILE | sed 's/CFG_ENABLE_KEEPALIVE_CMD_ECHO *=.*/CFG_ENABLE_KEEPALIVE_CMD_ECHO=0/g' > $TMPFILE
  cp $TMPFILE $CONFIGFILE
}

function delay() {
  if [ -z $CFG_KEEPALIVE_INTERVAL ]; then
    sleep 30
  else
    sleep "$CFG_KEEPALIVE_INTERVAL"
  fi
}

if [ ! "$CFG_ENABLE_KEEPALIVE" -eq "1" ]; then
  exit 0
fi

##
## Notify gateway on each adapter
while [ : ]; do
  getDeviceInfo
  TMPFILE=`mktemp`
  for ADAPTER in `/bin/ip link | awk '/^[0-9]+:/ {gsub(/:\s?/," "); print $2}'`; do
    IP=`/bin/ip addr show $ADAPTER | awk '/inet[^6](\/ether)?/ {gsub(/\/.*/, "", $2); print $2}'`
    
    if [ ! -z $CFG_GATEWAY_IP ]; then
        GATEWAY="$CFG_GATEWAY_IP"
    else
      GATEWAY=`/sbin/route -n | awk '/'$ADAPTER'$/ {
        if ($1=="0.0.0.0") { print $2; exit}
      }'`
    fi
    
    if [ -z $GATEWAY ]; then
      continue
    fi
    
    wget -q "http://$GATEWAY:$CFG_KEEPALIVE_GATEWAY_PORT/registerdev.php?deviceId=$DEVID" -O "$TMPFILE"
    CMD=`cat $TMPFILE | awk '{print $1; exit}'`
    if [ "$CMD" == "PING" ]; then
      cmd_ping
    elif [ "$CMD" == "ECHO" ]; then
      cmd_echo
    elif [ "$CMD" == "LOCK" ]; then
      cmd_lock
    fi
    rm $TMPFILE
  done
  delay
done
exit 0

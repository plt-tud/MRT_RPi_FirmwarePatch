#!/bin/bash

RPIROOT='./RPi_root'
ROOTFILES="etc sbin usr PLTVersion"

chmod +x "$RPIROOT/etc/rc.local"
chmod +x "$RPIROOT/etc/init.d/rc.local"
chmod +x "$RPIROOT/usr/bin/keepalive.sh"
chmod +x "$RPIROOT/usr/bin/setpipw.sh"
chmod +x "$RPIROOT/sbin/rpi_testOutputs"

tar -C "$RPIROOT" -cpzf ./PLT_RPi-Update.tgz $ROOTFILES


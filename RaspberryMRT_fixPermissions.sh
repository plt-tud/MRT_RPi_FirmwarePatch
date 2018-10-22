#!/bin/bash

#REPOFOLDER="/home/$USER/svn/RaspberryMRT"
REPOFOLDER=`pwd`

USER="ichrispa"
GROUP="users"

if [ ! `id -u` -eq 0 ]; then 
	echo ERROR: Must be run as root to setup RPi Root Filesystem permissions...; 
	exit -1
fi

chown root.root $REPOFOLDER/RPi_root -R

echo $REPOFOLDER

find $REPOFOLDER -name "*.sh" -exec chmod +x '{}' \;
find $REPOFOLDER -name check_dev -exec chmod +x '{}' \;
find $REPOFOLDER -name rc.local -exec chmod +x '{}' \;

exit 0

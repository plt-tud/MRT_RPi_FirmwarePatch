#!/bin/bash

. ../../etc/pltscripts.conf

if [ ! $CFG_SETPIPW_ONBOOT -eq 1 ]; then
  exit 0
fi

PIPW=`awk '/Serial/ {SN=substr($0, index($0,":")+1); gsub(/[ \t]+/,"",SN); print(substr(SN,length(SN)-5))}' /proc/cpuinfo`

TMP=`mktemp`
echo -e "$PIPW\n$PIPW" > "$TMP"

passwd pi < "$TMP"

rm "$TMP"
exit 0
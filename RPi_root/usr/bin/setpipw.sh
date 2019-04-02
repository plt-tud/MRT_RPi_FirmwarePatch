#!/bin/bash

. ../../etc/pltscripts.conf

echo "Raspbian GNU/Linux 9 \n \l" > /etc/issue

if [ ! $CFG_SETPIPW_ONBOOT -eq 1 ]; then
  exit 0
fi

PIPW=`awk '/Serial/ {SN=substr($0, index($0,":")+1); gsub(/[ \t]+/,"",SN); print(substr(SN,length(SN)-5))}' /proc/cpuinfo`

echo "User pi password has been set to the last bits of your cpu serial no: $PIPW" >> /etc/issue

TMP=`mktemp`
echo -e "$PIPW\n$PIPW" > "$TMP"

passwd pi < "$TMP"

rm "$TMP"
exit 0

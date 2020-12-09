#!/bin/bash
if
find / -name skripts.sh -exec {} \; > otchet.txt &&
mailx root@localhost < otchet.txt

then
exit 0
else 
echo "file not found"
fi

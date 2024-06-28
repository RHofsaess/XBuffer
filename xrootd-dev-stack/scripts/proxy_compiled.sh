#!/bin/bash

# add user
echo "xrootd:x:9997:9997::/home/xrootd:/bin/bash" >> /etc/passwd

# set permissions
chmod 777 -R /logs
chmod 777 -R /cache

# create log file
touch /logs/proxy_compiled.log
echo "START: $(date) ----------------------------" > /logs/proxy_compiled.log

# run proxy service
runuser -u xrootd -- /build/src/xrootd -c /xrdconfigs/xrootd-caching-server.cfg -l /logs/proxy_compiled.log
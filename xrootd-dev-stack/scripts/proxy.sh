#!/bin/bash

##### add user xrootd #####
echo "xrootd:x:9997:9997::/home/xrootd:/bin/bash" >> /etc/passwd

# set permissions
chmod 777 -R /logs
chmod 777 -R /cache

touch /logs/proxy.log
echo "START: $(date) ----------------------------" > /logs/proxy.log

# start proxy service
runuser -u xrootd -- xrootd -c /xrdconfigs/xrootd-caching-server.cfg -l /logs/proxy.log
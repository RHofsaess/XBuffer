#!/bin/bash
# This script sets up logging and starts an XRootD server container promoting /storage with the default production xrootd version.

#set permissions
chmod 777  /logs/server.log

# create log file
touch /logs/server.log
echo "START: $(date) ----------------------------" > /logs/server.log

# start xrootd server
runuser -u xrootd -- xrootd -c /xrdconfigs/xrootd-standalone.cfg -l /logs/server.log

sleep infinity
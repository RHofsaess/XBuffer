#!/bin/bash
# This script sets up logging and starts an XRootD server container promoting /storage with the compiled xrootd version.

#set permissions
chmod 777  /logs/server.log

# create log file
touch /logs/server_compiled.log
echo "START: $(date) ----------------------------" > /logs/server_compiled.log

# start xrootd server
runuser -u xrootd -- build/src/xrootd -c /xrdconfigs/xrootd-standalone.cfg -l /logs/server.log

sleep infinity
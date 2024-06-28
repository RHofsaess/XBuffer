#!/bin/bash
# This script sets up logging and starts a client container with the compiled xrootd version

# set permissions
chmod -R 777 /logs/

touch client_compiled.log
echo "START: $(date) ----------------------------" > client_compiled.log

# wait for startup of other containers and compilation
# Note: this may needs to be adapted
wait=20
echo "-------Waiting for containers to come up...-------"
for ((i=${wait}; i>0; i--)); do
  echo " Waiting for $i more seconds"
  sleep 1
done

# transfer a file:
build/src/XrdCl/xrdcp -f root://10.5.0.5:1094//storage/file.root . &> /logs/client_compiled.log
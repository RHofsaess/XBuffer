#!/bin/bash
# This script sets up logging and starts a data transfer

# set permissions
chmod -R 777 /logs/

touch /logs/client.log
echo "START: $(date) ----------------------------" > /logs/client.log

# wait for startup of other containers
# Note: this may needs to be adapted
wait=20
echo "-------Waiting for containers to come up...-------"
for ((i=${wait}; i>0; i--)); do
  echo " Waiting for $i more seconds"
  sleep 1
done

# transfer a file
xrdcp -f root://10.5.0.5:1094//storage/file.root . &> /logs/client.log
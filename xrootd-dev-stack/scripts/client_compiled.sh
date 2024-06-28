#!/bin/bash
# This script sets up logging and starts a client container with the compiled xrootd version

touch /logs/client_compiled.log
echo "START: $(date) ----------------------------" > /logs/client.log

# wait for startup of other containers
sleep 1000

# transfer a file with:
# XRD_CPUSEPGWRTRD=0 /build/src/xrootd -d 2 -f root://REDIRECTOR:1094//FILE.root . &> /logs/client.log
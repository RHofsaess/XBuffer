#!/bin/bash
#################################################
# This script starts an instance and runs the   #
# xrootd caching proxy. If an instance with the #
# same name is already running, it is stopped   #
# and restarted. Therefore, the script can also #
# be used for RESTARTING an instance!           #
# As a default, the images are pulled from      #
# dockerhub. But they can also be build locally.#
#################################################

# 1) TODO: adapt config paths
# ---------- Config ----------
IMAGE="rhofsaess/alma9_proxy_sha1" #"rhofsaess/cc7_proxy" # "rhofsaess/alma9_proxy"  # "rhofsaess/alma8_proxy" #pulled from https://hub.docker.com/u/rhofsaess 
BASEDIR=/path/to/basedir
WORKSPACE=/path/to/cache/basedir
CACHE=$WORKSPACE/cache
INSTANCE=proxy
# ----------------------------

# Check if workspace and exists
if [[ -d "$WORKSPACE" ]]; then
    if [[ -d "$CACHE" ]]; then
        echo "Cache directory exists."
    else
        mkdir -p $CACHE
    fi
else
    echo "The workspace '$WORKSPACE' does not exist."
    exit
fi

# Stop old instances with the same name, if running
running_instance=$(apptainer instance list | grep -w "^$INSTANCE\b")
if [[ -n $running_instance ]]; then
    echo "Instance '$instance_name' is running. Stopping it now..."
    apptainer instance stop "$INSTANCE"
    if [[ $? -eq 0 ]]; then
        echo "Instance '$INSTANCE' stopped successfully."
    else
        echo "Failed to stop instance '$INSTANCE'."
        return 1
    fi
fi

# Start the instance
apptainer instance start --bind $CACHE:/cache,$BASEDIR/proxy/:/proxy,$BASEDIR/configs:/xrdconfigs,$BASEDIR/cvmfs-grid-certs/grid-security:/etc/grid-security,$BASEDIR/logs:/logs,$BASEDIR/scripts:/scripts docker://${IMAGE} $INSTANCE

# Run the caching proxy
# 2) TODO: adapt the <PROXYNAME>
apptainer exec instance://proxy /bin/bash -c 'export X509_USER_PROXY=/proxy/<PROXYNAME>; xrootd -c /xrdconfigs/xrootd-caching-server.cfg -l /logs/proxy.log' &

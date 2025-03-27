#!/bin/bash
#################################################
# This script starts an instance, runs the     	#
# xrootd (caching) proxy, and starts the      	#
# monitoring, if enabled.			                  #
# The monitoring log is written to the file 	  #
# 'io.log', if not configured differently.	    #
# If an instance with the same name is already  #
# running, it is stopped and restarted. 	      #
# Therefore, the script can also be used for  	#
# RESTARTING an instance!           		        #
# As a default, the images are pulled from      #
# dockerhub. But they can also be build locally.#
#################################################
# ---------- Config ----------
source ../.env

if [[ ! $INSTANCE_CONFIG_EXPORTED -eq 1 ]]; then
    echo "Please make sure that the config is correct and exported!"
    exit 1
fi
# ----------------------------

echo "[$(date)]: Starting instance >>${INSTANCE}<<..." | tee -a "$LOGDIR"/main.log
# If caching should be used, a workspace is required
# Check if workspace exists
if [[ "$ENABLE_CACHE" -eq 1 ]]; then
    if [[ -d "$WORKSPACE" ]]; then
        if [[ -d "$CACHE" ]]; then
            echo "[$(date)]: Cache directory exists." | tee -a "$LOGDIR"/main.log
        else
            mkdir -p "$CACHE"
            echo "[$(date)]: Cache directory created." | tee -a "$LOGDIR"/main.log
        fi
    else
        echo "[$(date)]: [ERROR] The workspace '$WORKSPACE' does not exist." | tee -a "$LOGDIR"/main.log
        echo "[$(date)]: Please create one or disable caching!" | tee -a "$LOGDIR"/main.log
        exit 1
    fi
else
    echo "[$(date)]: Running without caching." | tee -a "$LOGDIR"/main.log
fi

# Check if a valid VOMS proxy is available
voms_remaining() {
    # function to check remaining time of voms proxy
    # return the remaining time in seconds
    echo "[$(date)]: Check remaining time of VOMS proxy" >> "$LOGDIR"/main.log
    command="export X509_USER_PROXY=/proxy/$(ls "$BASEDIR"/proxy/); voms-proxy-info | grep -m 1 timeleft | sed 's/^timeleft[[:space:]]*:[[:space:]]*//'"
    command_output=$(apptainer run --bind "$BASEDIR"/proxy/:/proxy docker://"${IMAGE}" bash -c "$command")
    echo "[$(date)]: ${command_output}" >> "$LOGDIR"/main.log
    IFS=":" read -r hours minutes seconds <<< "${command_output}"

    hours=$((10#$hours))
    minutes=$((10#$minutes))
    seconds=$((10#$seconds))
    total_seconds=$((hours * 3600 + minutes * 60 + seconds))

    echo $total_seconds
}

echo "[$(date)]: Checking for VOMS Proxy..." | tee -a "$LOGDIR"/main.log
if [[ $(find "$BASEDIR"/proxy -type f | wc -l) -eq 1 ]]; then
    echo "[$(date)]: Proxy file found: $(ls "$BASEDIR"/proxy). Checking validity..." | tee -a "$LOGDIR"/main.log
    # Check if proxy is valid:
    remaining=$(voms_remaining)
    if [[ ! remaining -gt 0 ]]; then
        echo "[$(date)]: VOMS proxy not valid!" | tee -a "$LOGDIR"/main.log
        exit 1
    else
        echo "[$(date)]: Found VOMS proxy with ${remaining}s remaining." | tee -a "$LOGDIR"/main.log
    fi
else
    echo "[$(date)]: [ERROR] In /proxy only one valid VOMS proxy is allowed!" | tee -a "$LOGDIR"/main.log
    exit 1
fi

exit 0

# Stop old instances with the same name, if running
running_instance=$(apptainer instance list | grep -w "^$INSTANCE\b")
if [[ -n $running_instance ]]; then
    echo "[$(date)]: Instance >>${INSTANCE}<< is running. Stopping it now..." | tee -a "$LOGDIR"/main.log
    apptainer instance stop "$INSTANCE"
    if [[ $? -eq 0 ]]; then
        echo "[$(date)]: Instance '$INSTANCE' stopped successfully." | tee -a "$LOGDIR"/main.log
    else
        echo "[$(date)]: Failed to stop instance '$INSTANCE'." | tee -a "$LOGDIR"/main.log
	exit 1
    fi
fi

# Start the instance and run the caching proxy
if [[ "$ENABLE_CACHE" -eq 1 ]]; then
    apptainer instance start --bind "$CACHE":/cache,"$BASEDIR"/proxy/:/proxy,"$BASEDIR"/configs:/xrdconfigs,"$BASEDIR"/cvmfs-grid-certs/grid-security:/etc/grid-security,"$BASEDIR"/logs:/logs,"$BASEDIR"/scripts:/scripts docker://"${IMAGE}" "$INSTANCE"
    apptainer exec instance://proxy /bin/bash -c 'export X509_USER_PROXY=/proxy/$( (ls /proxy) ); xrootd -c /xrdconfigs/xrootd_caching_server-simple.cfg -l /logs/proxy.log' &
    if [[ $? -eq 0 ]]; then
        echo "[$(date)]: Instance with caching started successfully." | tee -a "$LOGDIR"/main.log
    else
        echo "[$(date)]: Starting failed." | tee -a "$LOGDIR"/main.log
	exit 1
    fi
else
    apptainer instance start --bind "$BASEDIR"/proxy/:/proxy,"$BASEDIR"/configs:/xrdconfigs,"$BASEDIR"/cvmfs-grid-certs/grid-security:/etc/grid-security,"$BASEDIR"/logs:/logs,"$BASEDIR"/scripts:/scripts docker://"${IMAGE}" "$INSTANCE"
    apptainer exec instance://proxy /bin/bash -c 'export X509_USER_PROXY=/proxy/$( (ls /proxy) ); xrootd -c /xrdconfigs/xrootd_proxy_server-simple.cfg -l /logs/proxy.log' &
    if [[ $? -eq 0 ]]; then
        echo "[$(date)]: Instance without caching started successfully." | tee -a "$LOGDIR"/main.log
    else
        echo "[$(date)]: Starting failed." | tee -a "$LOGDIR"/main.log
	exit 1
    fi
fi

# Start monitoring, if enabled
if [[ "$ENABLE_MONIT" -eq 1 ]]; then
    ./start_monitoring.sh
else
    echo "[$(date)]: Additional monitoring disabled." | tee -a "$LOGDIR"/main.log
fi


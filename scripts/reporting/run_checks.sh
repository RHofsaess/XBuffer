#!/bin/bash
#################################################
# This script is used to regularly check on    #
# the instance and xrootd caching proxy. If one #
# of them is not running, the script automati-  #
# cally restarts the setup. The script is       #
# started from the management node  every 15    #
# minutes and reports to the new HF4 module.    #
#                                               #
# ++++++++++ Why is it not python? +++++++++++  #
# After longer discussion, we decided to go     #
# with plain bash to achieve a more             #
# general setup that works without any          #
# further requirements.                         #
#################################################
source ../../.env
# +++++ THINGS TO ADAPT +++++
RESTART=0  # 0:False, 1:True
# +++++++++++++++++++++++++++
now=$(date +%y%m%d)
echo "[$(date)]: +++++++ Starting Check +++++++" >> "$BASEDIR"/logs/reporting/"${now}".log

############### General Information ###############
get_hostname() {
	echo "[$(date)]: Running on: $(hostname)" >> "$BASEDIR"/logs/reporting/"${now}".log
	echo $(hostname)
}

get_timestamp() {
	timestamp=$(date +"%Y-%m-%dT%H:%M:%S")+01:00
	echo "[$(date)]: Timestamp: ${timestamp}" >> "$BASEDIR"/logs/reporting/"${now}".log
	echo "${timestamp}"
}

############### VOMS Proxy ###############

voms_exported() {
    # function to check if X509_USER_PROXY is exported
    # returns [0:proxy not set, 1:proxy set]
    echo "[$(date)]: Check X509_USER_PROXY set" >> "$BASEDIR"/logs/reporting/"${now}".log
    local expected_value="X509_USER_PROXY=/proxy/${PROXY}"

    command_output=$(apptainer exec instance://proxy /bin/bash -c 'task=$(ps aux | grep -v grep | grep xrootd | awk '\''{print $2}'\''); grep -ao "X509_USER_PROXY=/proxy/x509up_u232883" /proc/${task}/task/${task}/environ')  # Note: on the host, the pid differs from the container

    # Check if the variable is set and equals the expected value
    if [ "${command_output}" == "$expected_value" ]; then
        echo -e "\t${command_output}" >> "$BASEDIR"/logs/reporting/"${now}".log
	echo "1"
    else
        echo -e "\tX509_USER_PROXY not set" >> "$BASEDIR"/logs/reporting/"${now}".log
	echo "0"
    fi
}

voms_remaining() {
    # function to check remaining time of voms proxy
    # return the remaining time in seconds
    echo "[$(date)]: Check remaining time of voms proxy" >> "$BASEDIR"/logs/reporting/"${now}".log
    command_output=$(apptainer exec instance://proxy /bin/bash -c 'PROXY=x509up_u232883 /usr/bin/voms-proxy-info --file /proxy/x509up_u232883 | grep timeleft | awk '\''{print $3}'\')
    echo -e "\tTime left: ${command_output}" >> "$BASEDIR"/logs/reporting/"${now}".log
    IFS=":" read -r hours minutes seconds <<< "${command_output}"

    hours=$((10#$hours))
    minutes=$((10#$minutes))
    seconds=$((10#$seconds))
    total_seconds=$((hours * 3600 + minutes * 60 + seconds))

    echo $total_seconds
}

############### Instance and Caching Proxy ###############

instance_running() {
    # function to check, if the instance is running
    # CURRENTLY, THE ASSUMPTION IS THAT ONLY ONE INSTANCE IS RUNNING!!!
    # returns 0:running, 1:not running, 2: status "restarted"
    # NOTE: It can be that the caching proxy died but the instance is still running! Therefore, the second check
    echo "[$(date)]: Check, if apptainer instance is running:" >> "$BASEDIR"/logs/reporting/"${now}".log

    # first check, if an instance is running
    instance=$(apptainer instance list | awk 'NR>1 {print $1}')
    if [ -z "${instance}" ]; then
        echo -e "\tNo instance found!" >> "$BASEDIR"/logs/reporting/"${now}".log
        # self-healing mechanism:
        if [[ ${RESTART} -eq 1 ]]; then
            echo -e "\t[$(date)]: Restarting instance and proxy..." >> "$BASEDIR"/logs/reporting/"${now}".log
            nohup "$BASEDIR"/scripts/"${STARTSCRIPT}" >> "$BASEDIR"/logs/reporting/"${now}".log 2>&1 &
	    sleep 8  # wait for the instance to come up

            instance_restarted=$(apptainer instance list | awk 'NR>1 {print $1}')
            if [ -n "${instance_restarted}" ]; then
                echo -e "\t[$(date)]: Instance successfully restarted!" >> "$BASEDIR"/logs/reporting/"${now}".log
                echo "2"
            else
                echo -e "\t[ERROR]: Instance restart failed!" >> $BASEDIR/logs/reporting/${now}.log
                echo "1"
            fi
        fi
    fi
    echo -e "\t[$(date)]: Instance running." >> $BASEDIR/logs/reporting/${now}.log
    echo "0"
}

cachingproxy_running() {
    # function to check, if instance is running
    # NOTE: This function should only run after instance_running()
    command_output=$(apptainer exec instance://proxy /bin/bash -c 'ps aux | grep -v grep | grep xrootd')  # check, if caching proxy is running
    if [ -n "${command_output}" ]; then
        echo -e "\tInstance and proxy '${command_output}' running." >> $BASEDIR/logs/reporting/${now}.log  # both are running, since the check only works when the instance is running!
        echo "0"
    else
        echo -e "\t[ERROR] No caching proxy found!" >> $BASEDIR/logs/reporting/${now}.log
	if [[ $RESTART -eq 1 ]]; then
            echo -e "\t[$(date)]: Restarting instance and proxy..." >> $BASEDIR/logs/reporting/${now}.log
            nohup $BASEDIR/scripts/${STARTSCRIPT} >> $BASEDIR/logs/reporting/${now}.log 2>&1 &
            sleep 8  # wait for the instance to come up
	    echo "2"
        fi
	echo "1"
    fi
}

############### Fill State of Cache ###############
get_fill_state() {
    # NOTE: +++++ THIS NEEDS TO BE CHANGED IN FUTURE XROOTD VERSIONS +++++
    # Function to query the current estimated cache fill state from the proxy log.
    # Requires pfc logging to be enabled
    # returns the fillstate in TB
    echo "[$(date)]: Checking cache fill State:" >> $BASEDIR/logs/reporting/${now}.log 
    command_output=$(apptainer exec instance://proxy /bin/bash -c ' grep "estimated usage by files" /logs/proxy.log | tail -1 | awk '\''{print $11}'\')
    if [ -z "${command_output}" ]; then
        command_output=0
    fi
    echo -e "\tEstimated usage by files: ${command_output} bytes" >> $BASEDIR/logs/reporting/${now}.log
    echo "${command_output}"
}

############### SLURM Info ###############
n_running_nodes() {
    # returns the nummber of currently running nodes
    command_output=$(squeue --noheader | grep R | wc -l)
    echo "[$(date)]: Nummer of running nodes: ${command_output}" >> $BASEDIR/logs/reporting/${now}.log
    echo "${command_output}"
}

#running_nodes() {
# Returns list of the nodes running
#TODO
#}

next_start() {
    # returns the start of the next node
    command_output=$(squeue --start --noheader --format=%S | head -n1)+01:00
    echo "[$(date)]: Start time for next node: ${command_output}" >> $BASEDIR/logs/reporting/${now}.log
    echo "${command_output}"
}

############### Monitoring ###############
monit_running() {
    # checks if python3 is running
    command_output=$(apptainer exec instance://proxy /bin/bash -c 'ps -eo pid,cmd | grep python3 | grep -v grep')
    if [ -n "${command_output}" ]; then
        echo -e "[$(date)]: [Monitoring] running: ${command_output}" >> $BASEDIR/logs/reporting/${now}.log
	echo "1"
    else
        echo "0"
    fi
}

############### Future Extensions ###############
# - mode
# - running nodes
# - slurm job ids
# - siteconf

# -------------------------------------------------------------

# Format the output:
json_output="{"
json_output+="\"timestamp\": \"$(get_timestamp)\","
json_output+="\"hostname\": \"$(get_hostname)\","
json_output+="\"instance_running\": $(instance_running),"
json_output+="\"cachingproxy_running\": $(cachingproxy_running),"
json_output+="\"voms_remaining_s\": $(voms_remaining),"
json_output+="\"voms_exported\": $(voms_exported),"
json_output+="\"cache_fill_state_b\": $(get_fill_state),"
json_output+="\"next_start\": \"$(next_start)\","
json_output+="\"n_nodes\": $(n_running_nodes),"
json_output+="\"monit_running\": $(monit_running)"
json_output+="}"

echo "[$(date)]: Formatted output: ${json_output}" >> $BASEDIR/logs/reporting/${now}.log
echo $json_output


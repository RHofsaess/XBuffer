#!/bin/bash
#################################################
# This script is used to regularily check on    #
# the instance and xrootd caching proxy. If one #
# of them is not running, the script automati-  #
# cally restarts the setup. The script is 	#
# started from the management node  every 15    #
# minutes and reports to the new HF4 module.    #
#						#
# ++++++++++  Why is it not python? +++++++++++ #
# After longer discussion, we decided to go 	#
# with plain bash to achieve a more 		#
# generaliable setup that works without any	#
# further requirements.				#
#################################################
# TODO: split into different checks and make it more modular
# TODO: maybe switch to python...
BASEDIR=/home/hk-project-test-hep/scc-sdm-hep-0001/horeka_caching_setup
WORKSPACE="xrd-cache-26-05-24"

now=$(date +%y%m%d)
echo "[$(date)]: +++++++ Starting Full Horeka Check +++++++" >> $BASEDIR/logs/reporting/${now}.log

############### VOMS Proxy ###############

voms_exported() {
    # function to check if X509_USER_PROXY is exported
    # returns [0:proxy not set, 1:proxy set]
    echo "[$(date)]: Check X509_USER_PROXY set" >> $BASEDIR/logs/reporting/${now}.log
    local expected_value="X509_USER_PROXY=/proxy/x509up_u232883"

    command_output=$(apptainer exec instance://proxy /bin/bash -c 'task=$(ps aux | grep -v grep | grep xrootd | awk '\''{print $2}'\''); grep -ao "X509_USER_PROXY=/proxy/x509up_u232883" /proc/${task}/task/${task}/environ')  # Note: on the host, the pid differs from the container 

    # Check if the variable is set and equals the expected value
    if [ "${command_output}" == "$expected_value" ]; then
        echo -e "\t${command_output}" >> $BASEDIR/logs/reporting/${now}.log
	echo "1"
    else
        echo -e "\tX509_USER_PROXY not set" >> $BASEDIR/logs/reporting/${now}.log
	echo "0"
    fi
}

voms_remaining() {
    # function to check remaining time of voms proxy
    # return the remaining time in seconds
    echo "[$(date)]: Check remaining time of voms proxy" >> $BASEDIR/logs/reporting/${now}.log
    command_output=$(apptainer exec instance://proxy /bin/bash -c '/usr/bin/voms-proxy-info --file /proxy/x509up_u232883 | grep timeleft | awk '\''{print $3}'\')
    echo -e "\tTime left: ${command_output}" >> $BASEDIR/logs/reporting/${now}.log
    IFS=":" read -r hours minutes seconds <<< "${command_output}"

    hours=$((10#$hours))
    minutes=$((10#$minutes))
    seconds=$((10#$seconds))
    total_seconds=$((hours * 3600 + minutes * 60 + seconds))

    echo $total_seconds
}

############### Instance and Cache ###############

instance_running() {
    # function to check, if the instance is running
    # CURRENTLY, THE ASSUMPTION IS THAT ONLY ONE INSTANCE IS RUNNING!!!
    # returns 0:not running, 1:running, 2: status "restarted"
    # NOTE: It can be that the caching proxy died but the instance is still running! Therefore, the second check
    # TODO: in the future: restarts the proxy if not running!
    echo "[$(date)]: Check, if apptainer instance is running:" >> $BASEDIR/logs/reporting/${now}.log

    # first check, if an instance is running:
    instance=$(apptainer instance list | awk 'NR>1 {print $1}')
    if [ -z "${instance}" ]; then
        echo -e "\tNo instance found!" >> $BASEDIR/logs/reporting/${now}.log
        echo -e "\t[$(date)]: Restarting instance and proxy..." >> $BASEDIR/logs/reporting/${now}.log
        nohup $BASEDIR/scripts/start_XBuffer_instance.sh >> $BASEDIR/logs/reporting/${now}.log 2>&1 &
	sleep 8  # wait for the instance to come up

        instance_restarted=$(apptainer instance list | awk 'NR>1 {print $1}')
        if [ -n "${instance_restarted}" ]; then
            echo -e "\t[$(date)]: Instance successfully restarted!" >> $BASEDIR/logs/reporting/${now}.log
            echo "2"
        else
            echo -e "\t[ERROR]: Instance restart failed!" >> $BASEDIR/logs/reporting/${now}.log
            echo "0"
        fi
    else
        command_output=$(apptainer exec instance://proxy /bin/bash -c 'ps aux | grep -v grep | grep xrootd')
        if [ -n "${command_output}" ]; then
            echo -e "\tInstance '${instance}' and proxy '${command_output}' running." >> $BASEDIR/logs/reporting/${now}.log
            echo "1"
        else
            echo -e "\t[ERROR] Instance '${instance}' running, but no caching proxy found!" >> $BASEDIR/logs/reporting/${now}.log
	    echo -e "\t[$(date)]: Restarting instance and proxy..." >> $BASEDIR/logs/reporting/${now}.log
	    nohup ../start_XBuffer_instance.sh >> $BASEDIR/logs/reporting/${now}.log 2>&1 &
	    sleep 8  # wait for the instance to come up

            instance_restarted=$(apptainer instance list | awk 'NR>1 {print $1}')
		if [ -n "${instance_restarted}" ]; then
		    echo -e "\t[$(date)]: Instance successfully restarted!" >> $BASEDIR/logs/reporting/${now}.log
		    echo "2"
		else
		    echo -e "\t[ERROR]: Instance restart failed!" >> $BASEDIR/logs/reporting/${now}.log
		    echo "0"
		fi
        fi
    fi
}

cache_running() {  #DEPRECATED
    # function to check if caching proxy is running
    # returns: [0: caching proxy not running, 1:ok]
    # TODO: add auto-restarting if check fails
    echo "[$(date)]: Check, if XBuffer is running:" >> $BASEDIR/logs/reporting/${now}.log

    command_output=$(apptainer exec instance://proxy /bin/bash -c 'ps aux | grep -v grep | grep xrootd')
    if [ -n "${command_output}" ]; then
        echo -e "\t${command_output}" >> $BASEDIR/logs/reporting/${now}.log
	echo "1"
    else
        echo -e "\t[ERROR]: No caching proxy running!" >> $BASEDIR/logs/reporting/${now}.log
	echo "0"
    fi
}

############### Workspace ###############

check_remaining_WS_time() {
    # function to check the WS with the name 'xrd-cache'
    # if available, it returns the remaining time, else it returns 0
    echo "[$(date)]: Checking workspace '${WORKSPACE}':" >> $BASEDIR/logs/reporting/${now}.log

    # 1) check if the WS exists:
    exists=$(ws_list | grep id: | grep xrd-cache)
    if [ -z "${exists}" ]; then
        echo "[$(date)]: No workspace found!" >> $BASEDIR/logs/reporting/${now}.log
        echo "0"
    else
        echo -e "\tWorkspace '${exists}' found!" >> $BASEDIR/logs/reporting/${now}.log
    fi
    # 2) get remaining time
    command_output=$(ws_list | grep -A 1 "sdm-hep-0001-${WORKSPACE}" | grep "remaining time" | awk '{print $4, $5, $6, $7}')

    # convert to hours
    days=$(echo $command_output | grep -oP '\d+(?= days)')
    hours=$(echo $command_output | grep -oP '\d+(?= hours)')

    total_hours=$((days * 24 + hours))

    echo -e "\tRemaining time: ${total_hours}" >> $BASEDIR/logs/reporting/${now}.log   
    echo "${total_hours}"
}


############### Fil state of Cache ###############
get_fill_state() {
    # function to query the current estimated cache fill state
    # returns the fillstate in TB
    echo "[$(date)]: Checking cache fill State:" >> $BASEDIR/logs/reporting/${now}.log 
    command_output=$(apptainer exec instance://proxy /bin/bash -c ' grep "estimated usage by files" /logs/proxy.log | tail -1 | awk '\''{print $11}'\')
    echo -e "\tEstimated usage by files: ${command_output} bytes" >> $BASEDIR/logs/reporting/${now}.log
    echo "${command_output}"
}


# TODO:

############### Version Checking ###############
#check_versions() {
#}




############### Current Failure Rate  ###############


###############   ###############



# -------------------------------------------------------------

# test1: instance running?
test1=$(instance_running)
# test2: check if proxy is valid; returns remaining hours
test2=$(voms_remaining)
# test3: check if env variable is set
test3=$(voms_exported)
# test4: check WS remaining
test4=$(check_remaining_WS_time)
# test5: get fill state of cache
test5=$(get_fill_state)

################ DEPRECATED:
# test5: cache running? 
# test5=$(cache_running)
#json_output+="\"cache_running\": \"$test5\","

# Format the output:
json_output="{"
json_output+="\"instance_running\": \"$test1\","
json_output+="\"voms_remaining_s\": \"$test2\","
json_output+="\"voms_exported\": \"$test3\","
json_output+="\"remaining_WS_time_h\": \"$test4\","
json_output+="\"cache_fill_state_b\": \"$test5\""

json_output+="}"

echo $json_output


############### Extensions ###############
# get_fill_state() {}  # maybe once per day?
# test_transfer() {}  # ?


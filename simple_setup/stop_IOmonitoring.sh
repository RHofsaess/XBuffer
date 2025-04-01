#!/bin/bash
#################################################
# This script stops the monitoring and writes   #
# it to the main log.                           #
# The stopping of the process happens with a -2 #
# so that the buffered output is still written. #
#################################################
source ../.env

echo "[$(date)]: > Stopping monitoring." | tee -a "$LOGDIR"/main.log
monit_running=$(apptainer exec instance://${INSTANCE} /bin/bash -c "ps aux | grep -v grep | grep ifnop -q; echo \$?")
if [[ "$monit_running" -eq 1 ]]; then
    echo "[$(date)]: Monitoring not running!" | tee -a "$LOGDIR"/main.log
    exit 1
else
    pid=$(apptainer exec instance://"${INSTANCE}" /bin/bash -c "ps aux | grep -v grep | grep ifnop | awk '{print \$2}'")
    echo "[$(date)]: Stopping pid=$pid" | tee -a "$LOGDIR"/main.log
    apptainer exec instance://"${INSTANCE}" /bin/bash -c "kill -2 ${pid}"

    # Check if running
    monit_running=$(apptainer exec instance://"${INSTANCE}" /bin/bash -c "ps aux | grep -v grep | grep ifnop -q; echo \$?")
    if [[ "$monit_running" -eq 0 ]]; then
        echo "[$(date)]: Monitoring could not be stopped. Please check manually!" | tee -a "$LOGDIR"/main.log
    else
        echo "[$(date)]: Monitoring successfully stopped." | tee -a "$LOGDIR"/main.log
    fi
fi

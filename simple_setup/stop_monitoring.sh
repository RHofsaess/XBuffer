#!/bin/bash
#################################################
# This script stops the monitoring and writes   #
# it to the main log.                			      #
#################################################
source ../.env

echo "[$(date)]: > Stopping monitoring." | tee -a "$LOGDIR"/main.log
apptainer exec instance://"${INSTANCE}" /bin/bash -c "kill -2 $(ps aux | awk '/main.py/ && !/grep/ {print \$2}')"

monit_running=$(apptainer exec instance://"${INSTANCE}" /bin/bash -c "ps aux | grep -v grep | grep '/main.py' -q")
if [[ "$monit_running" -eq 0 ]]; then
    echo "[$(date)]: Monitoring could not be stopped. Please check manually!" | tee -a "$LOGDIR"/main.log
else
    echo "[$(date)]: Monitoring successfully stopped." | tee -a "$LOGDIR"/main.log
fi

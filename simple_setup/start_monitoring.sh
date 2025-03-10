#!/bin/bash
#################################################
# This script starts the monitoring. If it is 	#
# already running, it is restarted.		        #
# This starts the IFNOP I/O monitoring!         #
#################################################
source ../.env

echo "[$(date)]: Starting additional instance monitoring..." | tee -a $LOGDIR/main.log
# Check, if monitoring is running
monit_running=$(apptainer exec instance://proxy /bin/bash -c 'ps aux |grep -v grep | grep "/ifnop/main.py" -q')
if [[ "$monit_running" -eq 0 ]]; then
    echo "[$(date)]: Monitoring running. It will be killed and restarted.\n----------" | tee -a $LOGDIR/main.log
    ./stop_monitorin.sh
    echo "----------\n[$(date)]: Restarting..." | tee -a $LOGDIR/main.log
    apptainer exec instance://proxy /bin/bash -c "python3 $IFNOP_PATH/main.py --config $IFNOP_CONFIG" &
    if [[ "$?" -eq 0 ]]; then
        echo "[$(date)]: Monitoring successfully started." | tee -a $LOGDIR/main.log
    else
        echo "[$(date)]: Monitoring start failed." | tee -a $LOGDIR/main.log


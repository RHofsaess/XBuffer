#!/bin/bash
#################################################
# This script starts the monitoring. If it is   #
# already running, it is restarted.	            #
# This starts the IFNOP I/O monitoring!         #
#################################################
source ../.env

echo "[$(date)]: > Starting additional instance monitoring..." | tee -a "$LOGDIR"/main.log

# Check, if additional monitoring is installed
if [[ "$ENABLE_MONIT" -eq 0 ]]; then
    echo "[$(date)]: Monitoring is disabled (ENABLE_MONIT=0). Please first configure it properly in .env!" | tee -a "$LOGDIR"/main.log
    exit 1
fi

if [[ ! -d "$IFNOP_PATH" ]]; then
    echo "[$(date)]: Monitoring is enabled, but IFNOP is not available/set. Please validate the configuration or clone it!" | tee -a "$LOGDIR"/main.log
fi

# Check, if instance is running:
running_instance=$(apptainer instance list | grep -w "^$INSTANCE\b")
if [[ -n $running_instance ]]; then
    echo "[$(date)]: Instance >>${INSTANCE}<< found. Starting the I/O monitoring now..." | tee -a "$LOGDIR"/main.log
else
    echo "[$(date)]: [ERROR] Instance >>${INSTANCE}<< not found. Please make sure that the XBuffer instance is running." | tee -a "$LOGDIR"/main.log
    exit 1
fi

# Check, if monitoring is running
monit_running=$(apptainer exec instance://proxy /bin/bash -c 'ps aux |grep -v grep | grep "/ifnop/main.py" -q')
if [[ "$monit_running" -eq 0 ]]; then
    echo "[$(date)]: Monitoring running. It will be killed and restarted.\n----------" | tee -a "$LOGDIR"/main.log
    ./stop_monitorin.sh
    echo "----------\n[$(date)]: Restarting..." | tee -a "$LOGDIR"/main.log
    apptainer exec instance://"${INSTANCE}" /bin/bash -c "python3 $IFNOP_PATH/main.py --config $IFNOP_CONFIG" &
    if [[ "$?" -eq 0 ]]; then
        echo "[$(date)]: Monitoring successfully started." | tee -a "$LOGDIR"/main.log
    else
        echo "[$(date)]: Monitoring start failed." | tee -a "$LOGDIR"/main.log
        exit 1
    fi
else
    apptainer exec instance://"${INSTANCE}" /bin/bash -c "python3 $IFNOP_PATH/main.py --config $IFNOP_CONFIG" &
    if [[ "$?" -eq 0 ]]; then
        echo "[$(date)]: Monitoring successfully started." | tee -a "$LOGDIR"/main.log
    else
        echo "[$(date)]: Monitoring start failed." | tee -a "$LOGDIR"/main.log
        exit 1
    fi
fi

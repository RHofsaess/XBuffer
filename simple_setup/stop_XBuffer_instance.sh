#!/bin/bash
#################################################
# This script stops an instance garcefully and  #
# writes it to the main log. 			        #
#################################################
source ../.env

echo "[$(date)]: Stopping >>$1<<." | tee -a $LOGDIR/main.log

# Stop instances with the same name, if running
running_instance=$(apptainer instance list | grep -w "^$INSTANCE\b")
if [[ -n $running_instance ]]; then
    echo "Instance '$INSTANCE' is running. Stopping it now..." | tee -a $LOGDIR/main.log
    apptainer instance stop "$INSTANCE"
    if [[ $? -eq 0 ]]; then
        echo "Instance '$INSTANCE' stopped successfully." | tee -a /$LOGDIR/main.log
    else
        echo "Failed to stop instance '$INSTANCE'." | tee -a /$LOGDIR/main.log
	exit 1
    fi
fi


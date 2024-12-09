#!/bin/bash
#################################################
# This script stops the monitoring and		#
# writes it to the main log. 			#
#################################################
echo "[$(date)]: Stopping monitoring." | tee -a $LOGDIR/main.log
apptainer exec instance://proxy /bin/bash -c 'kill -2 $(ps aux | awk "/main.py/ && !/grep/ {print \$2}")'
echo "[$(date)]: Monitoring stopped." | tee -a $LOGDIR/main.log

#!/bin/bash
##################################################
# This script is deployed on the control node to #
# automatically push the grid proxy to the login #
# node. It runs regularly as a systemd timer.    #
# ---------------------------------------------- #
# To use for automatization, a running ssh-agent #
# is necessary and needs to be exported. The 	 #
# paths and files need to be adapted accordingly.#
##################################################

today=$(date +%d%h%y)
# 1) TODO: adapt path for logging
log_file="/path/to/logs/$today"
echo "[$(date)]: start the proxy copying..." >> "$log_file"

# 2) TODO: adapt path to your AUTH.sock
export SSH_AUTH_SOCK=/path/to/AUTH.sock
echo "SSH_AUTH_SOCK: ${SSH_AUTH_SOCK} " >> "$log_file"

# 3) TODO: adapt proxy and target
proxy=PROXY-FILE
target=x509up_u<USER-ID>

# Adding debug information before and after the scp command
echo "Starting SCP command for $proxy:" >> "$log_file"
{
    # 4) TODO: adapt scp command
    scp $proxy USER@XROOTD-NODE:xrootd-buffer/proxy/$target
    scp_exit_status=$?
    echo "SCP command exited with status: $scp_exit_status"
    if [ $scp_exit_status -ne 0 ]; then
        echo "SCP command failed."
    else
        echo "SCP command completed successfully."
    fi
} >> "$log_file" 2>&1

echo "Done." >> "$log_file"

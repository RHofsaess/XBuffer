#!/bin/bash
##################################################
# This script is deployed on the control node to #
# automatically copy the necessary grid certs to #
# the node. It is only required, when CVMFS is   #
# not available at the integrated site.          #
# ---------------------------------------------- #
# To use for automatization, a running ssh-agent #
# is necessary and needs to be exported and      #
# CVMFS needs to be available. The paths and     #
# files need to be adapted accordingly.          #
##################################################
today=$(date +%d%h%y)
# 1) TODO: adapt path for logging
log_file="/path/to/logs/$today"
echo "[$(date)]: start grid certificates copying..." >> "$log_file"

# 2) TODO: adapt path to your AUTH.sock
export SSH_AUTH_SOCK=/path/to/AUTH.sock
echo "SSH_AUTH_SOCK: ${SSH_AUTH_SOCK} " >> "$log_file"

# Adding debug information before and after the scp command
echo "Starting rsync of grid-security from CVMFS:" >> "$log_file"
{
    # 3) TODO: Adapt the rsync command
    rsync -az --delete /cvmfs/grid.cern.ch/etc/grid-security USER@XROOTD-NODE:xrootd-buffer/cvmfs-grid-certs
    rsync_exit_status=$?
    echo "rsync command exited with status: $rsync_exit_status"
    if [ $rsync_exit_status -ne 0 ]; then
        echo "rsync command failed."
    else
        echo "rsync command completed successfully."
    fi
} >> "$log_file" 2>&1

echo "Done." >> "$log_file"


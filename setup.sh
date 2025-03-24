#!/bin/bash
#################################################
# This script creates all necessary directories #
# and sets the permissions.                     #
# +++++ Adapt the BASEDIR for usage! +++++	#
#################################################

# ---------- Config ----------
ENV_FILE=".env"
BASEDIR=$(pwd)

echo "Set BASEDIR to $(pwd)"
sed -i "s|export BASEDIR=.*|export BASEDIR=$BASEDIR|" "$ENV_FILE"
# ----------------------------
mkdir -p $BASEDIR/proxy
mkdir -p $BASEDIR/cvmfs-grid-certs
mkdir -p $BASEDIR/logs/reporting
mkdir -p $BASEDIR/logs/slurm-logs  # For slurm based HPC centers
chmod -R 777 $BASEDIR/logs

touch $BASEDIR/logs/main.log
echo "[$(date)]: Directories created..." >> $BASEDIR/logs/main.log

# Get cvmfsexec
echo "[$(date)]: Get cvmfsexec and do initial setup..." >> $BASEDIR/logs/main.log
# This is required for updating /etc/grid-security
git clone https://github.com/cvmfs/cvmfsexec.git
cd ./cvmfsexec
./makedist -s osg

# Setup automated update service for /etc/grid-security
sed -i "s|^ExecStart=.*|ExecStart=${BASEDIR}/scripts/grid-security/setup_cvmfs.sh|" $BASEDIR/scripts/grid-security/gridsecurity.service

# Enable timer
systemctl --user daemon-reload
systemctl --user enable $BASEDIR/scripts/grid-security/gridsecurity.timer

# Get monitoring tool
echo "[$(date)]: Cloning ifnop..." >> $BASEDIR/logs/main.log
git clone https://github.com/RHofsaess/ifnop.git >> $BASEDIR/logs/main.log

echo "[$(date)]: Basic setup done." >> $BASEDIR/logs/main.log

echo "Next steps:"
echo "1) Adapt .env"
echo "2) Configure additional monitoring (OPTIONAL)"
echo "3) Put a valid VOMS proxy inside ./proxy. NOTE: in this directory must only be one file!!!"
echo "3) Setup of services:"
echo "   - Reporting"
echo "   - CVMFS grid-sec"
echo "   - "
echo "   - Optional: I/O node monitoring: adapt ifnop config file"
echo "3) Create"





# Reporting: STATUS +

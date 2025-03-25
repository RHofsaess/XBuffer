#!/bin/bash
#################################################
# This script creates all necessary directories #
# and sets the permissions.                     #
# Additionally, automation is deployed.         #
#################################################

# ---------- Config ----------
ENV_FILE=".env"
BASEDIR=$(pwd)

echo "Set BASEDIR to $(pwd)"
sed -i "s|export BASEDIR=.*|export BASEDIR=$BASEDIR|" "$ENV_FILE"
# ----------------------------
mkdir -p "$BASEDIR"/proxy
mkdir -p "$BASEDIR"/cvmfs-grid-certs
mkdir -p "$BASEDIR"/logs/reporting
mkdir -p "$BASEDIR"/logs/slurm-logs  # For slurm based HPC centers
chmod -R 777 "$BASEDIR"/logs

touch "$BASEDIR"/logs/main.log
echo "[$(date)]: Directories created..." >> "$BASEDIR"/logs/main.log

# Get cvmfsexec
echo "[$(date)]: Get cvmfsexec and do initial setup..." >> "$BASEDIR"/logs/main.log
# This is required for updating /etc/grid-security
git clone https://github.com/cvmfs/cvmfsexec.git
cd ./cvmfsexec || exit
./makedist -s osg
cd "$BASEDIR" || exit

# Setup automated update service for /etc/grid-security
sed -i "s|<Replace>|${BASEDIR}|g" "$BASEDIR"/scripts/grid-security/setup_cvmfs.sh
sed -i "s|^ExecStart=.*|ExecStart=${BASEDIR}/scripts/grid-security/setup_cvmfs.sh|" "$BASEDIR"/scripts/grid-security/gridsecurity.service

# Copy units
echo "[$(date)]: Copy units..." >> "$BASEDIR"/logs/main.log
cp "$BASEDIR"/scripts/grid-security/gridsecurity.timer ~/.config/systemd/user/
cp "$BASEDIR"/scripts/grid-security/gridsecurity.service ~/.config/systemd/user/
cp "$BASEDIR"/scripts/grid-security/gridsecurity-restart.service ~/.config/systemd/user/
echo "[$(date)]: UNITS: $(ls ~/.config/systemd/user/)" >> "$BASEDIR"/logs/main.log

# Make executable
chmod +x ./scripts/grid-security/setup_cvmfs.sh

# Enable timer
echo "[$(date)]: Enable CVMFS unit and timer" >> "$BASEDIR"/logs/main.log
systemctl --user daemon-reload
systemctl --user restart gridsecurity.service
systemctl --user enable gridsecurity.timer
systemctl --user start gridsecurity.timer

# Get monitoring tool
echo "[$(date)]: Cloning ifnop..." >> "$BASEDIR"/logs/main.log
git clone https://github.com/RHofsaess/ifnop.git >> "$BASEDIR"/logs/main.log

# Set config flag
sed -i "s|<set-via-setup-script>|1|g" "$BASEDIR"/.env
echo "[$(date)]: Basic setup done." >> "$BASEDIR"/logs/main.log

echo "Next steps:"
echo "1) Adapt .env"
echo "2) Configure additional monitoring (OPTIONAL)"
echo "3) Put a valid VOMS proxy inside ./proxy. NOTE: in this directory must only be one file!!!"
echo "3) Setup of services:"
echo "   - CVMFS grid-sec"
echo "   - Reporting"
echo "   - "
echo "   - Optional: I/O node monitoring: adapt ifnop config file"
echo "3) Create"



# Reporting: STATUS +

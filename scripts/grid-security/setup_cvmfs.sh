#!/bin/bash
# Script to set up cvmfs for copying /etc/grid-security
# We do not configure/deploy a squid here as it is only one download once in a while
BASEDIR=<Replace>
echo "[$(date)]: Updating /etc/grid-security..." >> "$BASEDIR"/logs/main.log
rm -r "$BASEDIR"/cvmfs-grid-certs/grid-security

cd "$BASEDIR"/cvmfsexec
./cvmfsexec grid.cern.ch -- cp -r /cvmfs/grid.cern.ch/etc/grid-security "$BASEDIR"/cvmfs-grid-certs
if [ $? -ne 0 ]; then
  echo "[$(date)]: Update failed." >> "$BASEDIR"/logs/main.log
else
  echo "[$(date)]: /etc/grid-security updated." >> "$BASEDIR"/logs/main.log
fi

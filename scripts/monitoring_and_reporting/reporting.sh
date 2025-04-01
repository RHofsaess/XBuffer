#!/bin/bash
#################################################
# This script is used for a systemd unit to     #
# regularly check the status of the setup and   #
# push it to opensearch.                        #
#                                               #
# For usage, a python venv must be created and  #
# the path adapted. The environment.txt must be #
# filled.                                       #
# The checks need to be implemented in the      #
# run_checks.sh script.                         #
#################################################
source ../../.env
source "$BASEDIR"/scripts/monitoring_and_reporting/reporting_venv/bin/activate
source "$BASEDIR"/scripts/monitoring_and_reporting/environment.txt && "$BASEDIR"/scripts/monitoring_and_reporting/run_checks.sh | \
        python3 "$BASEDIR"/scripts/monitoring_and_reporting/push_json_to_opensearch.py

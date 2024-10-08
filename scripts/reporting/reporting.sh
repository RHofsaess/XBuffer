#!/bin/bash
#################################################
# This script is used for a systemd unit to     #
# regularly check the status of the setup and   #
# push it to opensearch.                        #
#                                               #
# For usage, a python venv must be created and  #
# the path adapted. The environment.txt must be #
# filled.                                       #
#################################################
source /path/to/venv/bin/activate
source /path/to/environment.txt
/path/to/run_checks.sh | python3 /path/to/push_json_to_opensearch.py

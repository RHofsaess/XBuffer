# Logging and Reporting
To ensure a reliable operation of the service, a logging and reporting toolset is provided.
The idea is that a check script is running every X minutes that watches the setup and logs or reports the output to an opensearch.
NOTE: This is independent of the monitoring provided from the proxy itself and tools like e.g. `ifnop`.

Additionally, some self-healing mechanisms can be activated in the `run_checks.sh` that e.g. restart the service, if the check finds the service not running.

In principle, the watch service can be run in three ways:
- systemd-based reporting: A systemd unit and timer are used to regularly fetch and push status information to opensearch
- local logging: just log the status to file -- can be used as systemd timer too
- external management node via ssh: run the report script externally

If `systemctl --user` is available, this way should be preferred, as it avoids problems with e.g. MFA that would occur with external management nodes.

# Overview
- `environment.txt`: Includes the env variables the push script is reading.
- `environment.txt.example`: Example with more description.
- `init_index.txt`: Command for manually setting up an index in OS, including a fixed data type mapping. Can be used with curl/requests or from within the OS dev console. +++++ MAY NEEDS TO BE ADAPTED!! +++++
- `monit-cache.sh`: mpxstats summary monitoring for XRootD caching proxy.
- `monit-redirector.sh`: mpxstats summary monitoring for XRootD redirector.
- `push_json_to_opensearch.py`: The scripts reads the necessary env variables and a json from stdin and pushes it to OS. Usage: `$ source environment.txt && script_returning_json.sh | python push.py`
- `push_json_to_opensearch_with_mm.py`: Analog, but wth Mattermost alerting.
- `push_json_to_opensearch_manually.py`: Script for testing the OS connectivity. Can be used for initial index creation.
- `reporting.sh`: It sources the venv, exports the `environment.txt` to be accessible for the push script, runs the checks and optionally pushes the data to OS.
- `reporting_with_mm.sh`: It sources the venv, exports the `environment.txt` to be accessible for the push script, runs the checks pushes the data to OS and optionally sends mattermost alerts.
- `run_checks.sh`: This script runs all checks and returns a json as a string. This can be read-in by a push script. Everything is also logged to `logs/reporting`.
- `./systemd`: folder containing the user units for automation.
- `xrootd_influx_exporter.py`: Script for listening to UPD, digesting the xml of the xrd summary monitoring, and pushing it to influxDB.
- `xrootd_influx_exporter_flat.py`: Same but in flat format (like json).

# Setup
Several ways to set up the reporting are available.

## General
1) Run `setup_reporting.sh`
2) Adapt the `environment.txt`: Add OpenSearch and (optionally) Mattermost configs. An example is given.
3)

## OpenSearch (`systemd`-based)
1) Adapt the files. The `reporting_*.sh` is just a wrapper for the check script. You need to adapt the paths, also in the systemd units. #TODO outdated!
2) Add checks to `run_checks.sh` adapted to your needs. The script returns the check results as a json string.
3) +++++ OPTIONAL +++++ Push an index mapping manually to OS to ensure data types.
4) Copy the units to: `~/.config/systemd/user/`.
5) Reload: `$ systemctl --user daemon-reload`.
6) Enable the timer: `$ systemctl --user enable --now reporting.timer`.
7) Verify: `$ systemctl --user status reporting.timer` or `$ journalctl --user-unit reporting.service`.

### Setting Up the Data
???

## Mattermost Alert Bot
1) Create a bot in mattermost and give him for the beginning `system administrator` permissions (NOTE: This SHOULD BE CHANGED later!)
2) Get the bot's access token.
3) Verify the bot to be working: `$ curl -i -H 'authorization: Bearer <your token>' https://your.mattermost.com/api/v4/users/me`.
4) Query team and channel IDs: `$ curl -i -H 'authorization: Bearer <your token>' https://your.mattermost.com/api/v4/channels` or `teams` instead of `channels`.
NOTE: This only works with admin permissions. It can also be that the desired channel is on a different page. Then, add to the query: `.../v4/channels?page=1,2,3,4,...`, until you find the correct one.
5) Add alerts as you wish (according to the output of `run_checks.sh`) to the `prepare_report` function.
6) Adapt the scripts, units etc to correctly use `push_json_to_opensearch_with_mm.py` and add the required config keys to the environment.
7) Change the permissions of the bot to `Member` with the `post:all` permission set.

## Local
The setup can also run locally and we can log everything to file.
This can also be realized as a systemd timer by just adapting the `reporting.sh` to only run the check script without pushing.

## External
DEPRECATED

# Logging and Reporting
To ensure a reliable operation of the service, a logging and reporting toolset is provided.
The idea is that a check script is ran every X minutes that watches the setup and logs or reports the output to an opensearch.
NOTE: This is independend from the monitoring provided from the proxy itself and tools like e.g. `ifnop`.

Additionally, some self-healing mechanisms can be activated in the `run_checks.sh` that e.g. restart the service, if the check finds the service not running.

In principle, the watch service can be ran in three ways:
- systemd-based reporting: A systemd unit and timer are used to regulary fetch and push status information to opensearch
- local logging: just log the status to file -- can be used as systemd timer too
- external management node via ssh: run the report script externally
If `systemctl --user` is available, this way should be prefered, as it avoids problems with e.g. MFA that would occur with external management nodes.

# Overview
- `environment.txt`: Includes the env variables the push script is reading.
- `init_index.txt`: Command for manually setting up an index in OS, including a fixed data type mapping. Can be used with curl/requests or from within the OS dev console. +++++ MAY NEEDS TO BE ADAPTED!! +++++
- `monit-cache.sh`: mpxstats summary monitoring for XRootD caching proxy.
- `monit-redirector.sh`: mpxstats summary monitoring for XRootD redirector.
- `push_json_to_opensearch.py`: The scripts reads the necessary env variables and a json from stdin and pushes it to OS. Usage: `$ source environment.txt && script_returning_json.sh | python push.py`
- `push_json_to_opensearch_manually.py`: Script for testing the OS connectivity. Can be used for initial index creation.
- `reporting.sh`: It sources the venv, exports the `environment.txt` to be accessible for the push script, runs the checks and optionally pushes the data to OS.
- `run_checks.sh`: This script runs all checks and returns a json as a string. This can be read-in by a push script. Everything is also logged to `logs/reporting`.
- `./systemd`: folder containing the user units for automatization.
- `xrootd_influx_exporter.py`: Script for listening to UPD, digesting the xml of the xrd summary monitoring, and pushing it to influxDB.
- `xrootd_influx_exporter_flat.py`: Same but in flat format (like json).

# Setup
Several ways to set up the reporting are available.

## OpenSearch (`systemd`-based)
1) Create a python venv: `$ python3 -m venv venv` and `pip install opensearch-py` into it.
2) Adapt the files. The `reporting.sh` is just a wrapper for the check script. You need to adapt the paths, also in the systemd units, and the `run_checks.sh` to your needs.
3) +++++ OPTIONAL +++++ Push an index mapping manually to OS to ensure data types.
3) Copy the units to: `~/.config/systemd/user/`
4) Reload: `$ systemctl --user daemon-reload`
5) Enable the timer: `$ systemctl --user enable --now reporting.timer`
6) Verify: `$ systemctl --user status reporting.timer` or `$ journalctl --user-unit reporting.service`

### Setting Up the Data


## Local
The setup can also run locally and we can log everything to file.
This can also be realized as a systemd timer by just adapting the `reporting.sh` to only run the check script without pushing.

## External
TODO


# TODO
- provide xrd push scripts to OpenSearch
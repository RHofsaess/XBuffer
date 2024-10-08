# Logging and Reporting
To ensure a reliable operation of the service, a logging and reporting toolset is provided.
The idea is that a check script is ran every X minutes that watches the setup and logs or reports the output to an opensearch.

Additionally, some self-healing mechanisms can be activated that e.g. restart the service, if the check finds the service not running.

In principle, the watch service can be ran in three ways:
- systemd-based reporting: A systemd unit and timer are used to regulary fetch and push status information to opensearch
- local logging: just log the status to file -- can be used as systemd timer too
- external management node via ssh: run the report script externally

# Setup
Several ways to set up the reporting are available.

## `systemd`-based
1) Create a python env: `$ python3 -m venv venv` and install `opensearch-py` into it
2) Adapt the files. The reporting.sh is just a wrapper for the check script.
3) Copy the units to ~/.config/systemd/user/
4) Reload: `$ systemctl --user daemon-reload`
5) Enable the timer: `$ systemctl --user enable --now reporting.timer`
6) Verify: `$ systemctl --user status reporting.timer` or `$ journalctl --user-unit reporting.service`

## Local
The setup can also run locally and we can log everything to file.
This can also be realized as a systemd timer by just adapting the `reporting.sh` to only run the check script.

## External
TODO

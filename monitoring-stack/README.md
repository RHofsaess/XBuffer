# Monitoring Stack
With this docker compose stack, the full DB monitoring backend can be deployed.
The monitoring containers for XRootD are integrated for simplicity reasons with networking between containers.
Alternatively, it is of course also possible to push the monitoring data to existing data bases.

## Overview
The stack includes two types of databases for the different kinds of monitoring.

### OpenSearch
OpenSearch is used for event based monitoring, representing the status for the setup, which can later on be used for alerts etc
This includes, e.g.,  the fill state of the cache and the validity of the voms proxy.
Furthermore, it can be used for the detailed XRootD monitoring to get a detailed per event index.

### Influx
Influx is used for the continuous time series monitoring, including:
- XRootD mpxstat summary monitoring (pushed manually with dedicated script)
- I/O monitoring, e.g. with my self-made ifnop

## Setup
At first, the .env file must be filled.
Then, the `init.sh` should be executed to create the necessary directories and set the permissions.
This also sets some recommended parameters for the databases.
Now, source the env file and run the `init.sh` script.
Lastly, start the compose stack.

After the initial setup, additional users (and access tokens) can be created to do a proper user and access management with matching security policies, if desired.

## Tl;dr
1) fill `.env` file
2) `$ source .env`
3) `$ source init.sh`
4) `$ docker compose docker-compose.yml -d`

# Monitoring Stack
With this docker compose stack, the full DB monitoring backend can be deployed.
The monitoring containers for XRootD are integrated for simplicity reasons with networking between containers.
Alternatively, it is of course also possible to push the monitoring data to existing databases.

## Overview
The stack includes two types of databases for the different kinds of monitoring.

### OpenSearch
OpenSearch is used for event based monitoring, representing the status for the setup, which can later on be used for alerts etc.
This includes, e.g.,  the fill state of the cache and the validity of the voms proxy.
Furthermore, it can be used for the detailed XRootD monitoring to get a detailed per event index, including verbose transfer and cache hit information.

### InfluxDB
InfluxDB is used for the continuous time series monitoring, including:
- XRootD mpxstat summary monitoring (pushed manually with dedicated script)
- I/O monitoring, e.g. with my self-made ifnop

### Additional XRootD Monitoring
Additionally, two monitoring containers are included in the `docker-compose.yml`.
The two containers read the UPD stream from the XBuffer (as configured in the XRootD config).
Exemplary, two containers for an XCache/XBuffer and the local GridKa redirector are provided.

In addition, the full monitoring from XRootD can be caught (like e.g. the Xrd Monitoring Shoveler is doing).
But for this, an additional queuing system is recommended, such as rabbitMQ or activeMQ.
Note that XRootD does not (yet) provide a tool for digesting the verbose (bit) streams. 
I typically just caught the parts that were interesting for me manually. 
Alternatively, the streams can be digested directly at the site and pushed to an Opensearch with a tool like: [xrootd-streammon](https://github.com/maxfischer2781/xrootd-streammon) or an own creation.

## Setup
At first, the .env file must be filled.
Then, the `init.sh` should be executed to create the necessary directories and set the permissions.
This also sets some recommended parameters for the databases.
Now, source the env file and run the `init.sh` script.
Lastly, start the compose stack.

After the initial setup, additional users (and access tokens) can be created to do a proper user and access management with matching security policies, if desired.
For OpenSearch, it can also be useful to create the index mapping manually.
For this, `init_OS_index.txt` needs to be adapted to the `run_checks.sh` script.


## Tl;dr
1) Fill `.env` file
2) Comment out or adapt the optional parts in the `docker-compose.yml` 
3) `$ source .env`
4) `$ source init.sh`
5) `$ docker compose docker-compose.yml -d`

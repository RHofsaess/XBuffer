# xrootd-buffer
This repository provides some tools to enhance the integration of HPC into WLCG. It especially aims at the mitigation of data access bottlenecks.\
Additionally, tools and scripts for optimizing the operation of such (opportunistic) resources are provided.

The goal is to provide a setup that can run with minimal permissions on most HPC centers!

# Why Buffer?


#Challenge and Motivation
TODO



# Content

# Images
This directory contains the Dockerfiles for the XBuffer containers.
Essentially, they just have all XRootD related software installed.
Currently, Alma9 is available as a production and a  version running.

The prebuilt images are available at https://hub.docker.com/u/rhofsaess.
If you do not trust me, just build them yourself ;-) `$ docker built -t your-dockerhub-username/image-name .` from within the according directory.\
After pushing to dockerhub with `$ docker push your-dockerhub-username/image-name`, they are available for bootstrapping with apptainer from dockerhub (NOTE: maybe, you need to do a `$ docker login` before pushing).

## Scripts
This directory includes all scripts necessary for automatization of the setup and monitoring. Additionally, some other tools are provided (that may be outsourced in the future in own repositories).



# Setup

## Technical Prerequisites
- apptainer
- usernamespaces
- ideally CGroups v2
- if caching: available storage
- for additional monitoring: an InfluxDB and an OpenSearch

## Caching
Caching can be useful but strongly depends on the available space and the used datasets (and data tiers).
These together define the turnaround rate of the cache.
Only if a decent cache hit rate is expected, caching is useful.
This therefore has to be considered carefully. 
In general, only the caching of NanoAOD seems to be really improving things but it of course strongly depends on the overall scenario.

For a parallel filesystem (with quota), such as GPFS, the caching of streamed blocks can be very imperformant if the blocksizes do not align.
XRootD should therefore be configured to match the FS.
For further info, see e.g. https://www.ibm.com/docs/en/storage-scale-ece/5.1.8?topic=vdisks-block-size https://www.reddit.com/r/IBM/comments/18iepjz/gpfs_question_on_setting_block_size/

As an alternative, the scratch space per node could also be used for caching.
ATLAS used that in the past with virtual placement.
In case of HoreKa, this is not required and not recommended.

## Automation
- /etc/grid-security is automatically updated from CVMFS once a day. For this, a systemd --user timer is used.


## Monitoring and Reporting

# Tl;dr

1) `$ git clone https://github.com/RHofsaess/XBuffer.git`
2) `$ cd XBuffer; source setup.sh`
3) Copy a valid VOMS proxy to `./proxy` 
4) Adapt `.env`
5) Start the XBuffer instance: `$ ./scripts/start_XBuffer_instance.sh`
6) Adapt `ifnop` config, if additional monitoring is desired. (**OPTIONAL**)
7) Start the additional monitoring (**OPTIONAL**)
8) Add reporting (**OPTIONAL**)


# TODO test start proxy 


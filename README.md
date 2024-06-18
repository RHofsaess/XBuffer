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
Currently, we have a slc7 and a Alma9 version running.

The prebuilt images are available at https://hub.docker.com/u/rhofsaess.
If you do not trust me, just build them yourself ;-) `$ docker built -t your-dockerhub-username/image-name .` from within the according directory.\
After pushing to dockerhub with `$ docker push your-dockerhub-username/image-name`, they are available for bootstrapping with apptainer from dockerhub (NOTE: maybe, you need to do a `$ docker login` before pushing).

## Scripts
This directory includes all scripts necessary for automatization of the setup and monitoring. Additionally, some other tools are provided (that may be outsourced in the future in own repositories).



# Setup

## Cache

### Considerations
- size: how fast a full turnaround? -> bandwidth, expected data and "required" cache hit rate need to be evaluated 
- parallel FS (with quota):
  - gpfs? https://www.ibm.com/docs/en/storage-scale-ece/5.1.8?topic=vdisks-block-size https://www.reddit.com/r/IBM/comments/18iepjz/gpfs_question_on_setting_block_size/

- scratch space per node -> not ideal but possible

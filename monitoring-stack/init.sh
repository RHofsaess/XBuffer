#!/bin/bash
########## Directories ##########
# Create required directories for the docker bind mounts
mkdir -p DB/influx/data
mkdir -p DB/grafana
mkdir -p DB/OS
mkdir logs; chmod 777 ./logs 
chmod 777 ./DB

########## OpenSearch ##########
# Documentation: https://opensearch.org/docs/latest/install-and-configure/install-opensearch/docker/#linux-settings
sudo swapoff -a
echo "vm.max_map_count=262144" >> /etc/sysctl.conf
sysctl -p
cat /proc/sys/vm/max_map_count


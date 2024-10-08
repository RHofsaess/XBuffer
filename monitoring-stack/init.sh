#!/bin/bash
mkdir -p data/OS

# Documentation: https://opensearch.org/docs/latest/install-and-configure/install-opensearch/docker/#linux-settings
sudo swapoff -a
echo "vm.max_map_count=262144" >> /etc/sysctl.conf
sysctl -p
cat /proc/sys/vm/max_map_count


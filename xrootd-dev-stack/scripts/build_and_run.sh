#!/bin/bash
# Instructions taken from: https://xrootd-howto.readthedocs.io/en/latest/Compile/

#eval `git config --global --add safe.directory /xrootd`
#eval `git config --global --add safe.directory /xrootd/src/XrdCeph`
git config --global --list

##### building ####
cd /build
cmake3 -DCMAKE_INSTALL_PREFIX=. ../xrootd
###########################################
# more options:
#    support VOMS: -DENABLE_VOMS=True
#    support HTTP TPC: -DENABLE_VOMS=True -DBUILD_MACAROONS=1
#    support XrdClHTTP: -DXRDCLHTTP_SUBMODULE=1 (built by default, no longer needed)
#    support Erasure Coding: -DENABLE_XRDEC=True
#    support ASAN (CentOS 8 only): -DENABLE_ASAN=True
###########################################
echo "+++++ NOTE: if the building fails, try to comment in the 'make clean' "
#make clean
make -j 8

/build/src/xrootd -v
echo "Compilation finished. Starting proxy server..."

##### add user xrootd #####
echo "xrootd:x:9997:9997::/home/xrootd:/bin/bash" >> /etc/passwd

# set permissions
chmod -R 777 /logs
chmod -R 777 /cache

# clean cache:
echo "Cleaning cache."
echo "+++++ If you do not want the cache to be cleaned each run, comment out the following line! +++++"
# -------------
rm -r /cache/*
# -------------

# create log file
touch /logs/proxy_build_run.log
# set permission again (necessary for initial run)
chmod -R 777 /logs
echo "START: $(date) ----------------------------" > /logs/proxy_build_run.log

##### start server #####
runuser -u xrootd -- /build/src/xrootd -c /xrdconfigs/xrootd-caching-server.cfg -l /logs/proxy_build_run.log
# TODO make type selectable via env var!

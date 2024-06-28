#!/bin/bash
# Instructions taken from: https://xrootd-howto.readthedocs.io/en/latest/Compile/

#eval `git config --global --add safe.directory /xrootd`  # tbt
#eval `git config --global --add safe.directory /xrootd/src/XrdCeph`  # tbt
git config --global --list

##### building #####
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

# // more commands to be added if necessary...

echo "Done."



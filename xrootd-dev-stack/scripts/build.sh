#!/bin/bash
#eval `git config --global --add safe.directory /xrootd`  # tbt
#eval `git config --global --add safe.directory /xrootd/src/XrdCeph`  # tbt
git config --global --list

cd /xrootd

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
make -j 8

/build/src/xrootd -v

# // more commands to be added if necessary...

echo "Done."



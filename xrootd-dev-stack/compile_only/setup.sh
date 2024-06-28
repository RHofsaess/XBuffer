#!/bin/bash

# clone xrootd
basedir=$(pwd)
git clone https://github.com/xrootd/xrootd.git
cd xrootd

git submodule init
# optional packages:
#git submodule update -- src/XrdClHttp
#git submodule update -- src/XrdCeph

# for latest http support:
#cd src
#git clone git@github.com:xrootd/xrdcl-http
#mv XrdClHttp XrdClHttp.save
#mv xrdcl-http XrdClHttp
#cd ..

cd $basedir
mkdir build
cd ./build

cd $basedir


xrootd -v

echo "Done."

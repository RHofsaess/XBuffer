#!/bin/bash

# This script prepares the full xrd-dev-stack with building and running testjobs in a full setup with remote/local server, proxy, and client.
# The images are provided from my dockerhub.
# TODO: add multiple clients

# 1) Create directories
# Since docker is sometimes a little complicated and the xrootd user does not always has the same uid, we make everythin 777 for simplicity

mkdir logs; chmod 777 logs
mkdir cache; chmod 777 cache

# 2) Get XRootD
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

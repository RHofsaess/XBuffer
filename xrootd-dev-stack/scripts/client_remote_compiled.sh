#!/bin/bash
# This script sets up logging and starts a remote data transfer with the self compiled xrootd version

# set permissions
chmod -R 777 /logs/

touch /logs/client_remote_compiled.log
echo "START: $(date) ----------------------------" > /logs/client_remote_compiled.log

# wait for startup of other containers and compilation
# Note: this may needs to be adapted
wait=20
echo "-------Waiting for containers to come up...-------"
for ((i=${wait}; i>0; i--)); do
  echo " Waiting for $i more seconds"
  sleep 1
done

# transfer a file
build/src/XrdCl/xrdcp -f root://eospublic.cern.ch//eos/opendata/cms/Run2016H/DoubleMuon/NANOAOD/UL2016_MiniAODv2_NanoAODv9-v1/2510000/B7AA7F04-5D5F-514A-83A6-9A275198852C.root /logs &> /logs/client_remote_compiled.log
#build/src/XrdCl/xrdcp -f root://eospublic.cern.ch//eos/opendata/cms/Run2016H/DoubleMuon/NANOAOD/UL2016_MiniAODv2_NanoAODv9-v1/2510000/183BFB78-7B5E-734F-BBF5-174A73020F89.root /logs &> /logs/client_remote_compiled.log
#build/src/XrdCl/xrdcp -f root://eospublic.cern.ch//eos/opendata/cms/Run2016H/DoubleMuon/NANOAOD/UL2016_MiniAODv2_NanoAODv9-v1/2510000/2C6A0345-8E2E-9B41-BB51-DB56DFDFB89A.root /logs &> /logs/client_remote_compiled.log
#build/src/XrdCl/xrdcp -f root://eospublic.cern.ch//eos/opendata/cms/Run2016H/DoubleMuon/NANOAOD/UL2016_MiniAODv2_NanoAODv9-v1/2510000/B7AA7F04-5D5F-514A-83A6-9A275198852C.root /logs &> /logs/client_remote_compiled.log
#build/src/XrdCl/xrdcp -f root://eospublic.cern.ch//eos/opendata/cms/Run2016H/DoubleMuon/NANOAOD/UL2016_MiniAODv2_NanoAODv9-v1/2510000/8A696857-C147-B04A-905A-F85FB76EDA23.root /logs &> /logs/client_remote_compiled.log
#build/src/XrdCl/xrdcp -f root://eospublic.cern.ch//eos/opendata/cms/Run2016H/DoubleMuon/NANOAOD/UL2016_MiniAODv2_NanoAODv9-v1/2510000/B7AA7F04-5D5F-514A-83A6-9A275198852C.root /logs &> /logs/client_remote_compiled.log
#build/src/XrdCl/xrdcp -f root://eospublic.cern.ch//eos/opendata/cms/Run2016H/DoubleMuon/NANOAOD/UL2016_MiniAODv2_NanoAODv9-v1/2510000/8A696857-C147-B04A-905A-F85FB76EDA23.root /logs &> /logs/client_remote_compiled.log
#build/src/XrdCl/xrdcp -f root://eospublic.cern.ch//eos/opendata/cms/Run2016H/DoubleMuon/NANOAOD/UL2016_MiniAODv2_NanoAODv9-v1/2510000/F5E234F9-1E9C-0042-B395-AB6407E4A336.root /logs &> /logs/client_remote_compiled.log
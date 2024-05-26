FROM gitlab-registry.cern.ch/linuxsupport/cc7-base

MAINTAINER Robin Hofsaess <Robin.Hofsaess@kit.edu>

# add EPEL
RUN yum -y update && yum -y clean all
run yum -y install epel-release

# install xrootd with all additions
run yum -y update
run yum -y install \
    xrootd-client xrootd-client-devel xrootd-client-libs xrootd-client-libs \
    xrootd-server xrootd-server-devel xrootd-server-libs \
    xrootd-devel \ 
    xrootd-doc \
    xrootd-fuse \
    xrootd-libs \
    xrootd-private-devel \
    xrootd-scitokens \
    xrootd-voms \
    python3-xrootd

# other packages
run yum -y install vim voms-clients-java

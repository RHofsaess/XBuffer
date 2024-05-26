FROM gitlab-registry.cern.ch/linuxsupport/alma9-base:latest

MAINTAINER Robin Hofsaess <Robin.Hofsaess@kit.edu>

RUN dnf -y update && dnf -y clean all

# add EPEL
RUN dnf install -y 'dnf-command(config-manager)'
RUN dnf config-manager --set-enabled crb
RUN dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm

# Workaround for old dcache doors
RUN dnf -y install crypto-policies-scripts
RUN update-crypto-policies --set DEFAULT:SHA1

# install xrootd with all additions
RUN dnf -y install \
        xrootd-client xrootd-client-devel xrootd-client-libs \
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
RUN dnf install -y vim sudo voms-clients-java

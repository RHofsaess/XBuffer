FROM gitlab-registry.cern.ch/linuxsupport/alma9-base:latest

########################## INFO ###############################
# Current version: XRootD v5.7.1                              #
# Image available at: rhofsaess/alma9_5-7-1 or                #
# rhofsaess/alma9_5-7-1_sha1                                  #
###############################################################
MAINTAINER Robin Hofsaess <Robin.Hofsaess@kit.edu>

RUN dnf -y update && dnf -y clean all

# Add EPEL
RUN dnf install -y 'dnf-command(config-manager)'
RUN dnf config-manager --set-enabled crb
RUN dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm

# Add the xrootd repository directly
RUN curl -L https://cern.ch/xrootd/xrootd.repo -o /etc/yum.repos.d/xrootd.repo

# Workaround for old dcache doors
#RUN dnf -y install crypto-policies-scripts
#RUN update-crypto-policies --set DEFAULT:SHA1

# install xrootd with all additions
RUN dnf -y install --enablerepo=xrootd-stable\
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

# Python
RUN dnf install -y python3-devel \
                   python3.9-pip
RUN python3 -m pip install -U pip

# Monitoring
RUN dnf install -y lsof
RUN python3 -m pip install pandas influxdb-client psutil

# Other packages
RUN dnf install -y vim sudo voms-clients-java

RUN xrootd -v


FROM gitlab-registry.cern.ch/linuxsupport/alma9-base:latest

########################## INFO ###############################
# Image available at: rhofsaess/alma9_<VERSION>               #
# NOTE: SHA1 is enabled for now                               #
###############################################################
MAINTAINER Robin Hofsaess <Robin.Hofsaess@kit.edu>

ARG XROOTD_VERSION

RUN dnf -y update && dnf -y clean all

# Add EPEL
RUN dnf install -y 'dnf-command(config-manager)'
RUN dnf config-manager --set-enabled crb
RUN dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm

# Add the xrootd repository directly
RUN curl -L https://cern.ch/xrootd/xrootd.repo -o /etc/yum.repos.d/xrootd.repo

# Workaround for old dcache doors
RUN dnf -y install crypto-policies-scripts
RUN update-crypto-policies --set DEFAULT:SHA1

# install xrootd with all additions
RUN dnf -y install --enablerepo=xrootd-stable \
        xrootd-client-${XROOTD_VERSION} xrootd-client-devel-${XROOTD_VERSION} xrootd-client-libs-${XROOTD_VERSION} \
        xrootd-server-${XROOTD_VERSION} xrootd-server-devel-${XROOTD_VERSION} xrootd-server-libs-${XROOTD_VERSION} \
        xrootd-devel-${XROOTD_VERSION} \
        xrootd-doc \
        xrootd-fuse-${XROOTD_VERSION} \
        xrootd-libs-${XROOTD_VERSION} \
        xrootd-private-devel-${XROOTD_VERSION} \
        xrootd-scitokens-${XROOTD_VERSION} \
        xrootd-voms-${XROOTD_VERSION} \
        python3-xrootd-${XROOTD_VERSION}

# ########## Optional ##########

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


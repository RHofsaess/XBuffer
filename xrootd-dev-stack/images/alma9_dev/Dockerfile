FROM gitlab-registry.cern.ch/linuxsupport/alma9-base

##################### INFO ######################################
# available at: rhofsaess/alma9_dev or rhofsaess/alma9_dev_sha1 #
# Last tested with XRootD v5.6.9                                #
#################################################################
MAINTAINER Robin Hofsaess <Robin.Hofsaess@kit.edu>

RUN dnf -y update && dnf -y clean all

# add EPEL
RUN dnf install -y 'dnf-command(config-manager)'
RUN dnf config-manager --set-enabled crb
RUN dnf install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm

# Workaround for old dcache doors
#RUN dnf -y install crypto-policies-scripts
#RUN update-crypto-policies --set DEFAULT:SHA1

# add packages
RUN  dnf install -y expect \
                    perl \
                    policycoreutils \
                    selinux-policy \
                    readline-devel \
                    libxml2-devel \
                    curl \
                    libcurl-devel \
                    libmacaroons \
                    libmacaroons-devel \
                    json-c \
                    json-c-devel \
                    uuid \
                    libuuid-devel \
                    openssl-devel \
                    davix-libs \
                    davix-devel \
                    voms \
                    voms-devel \
                    fuse \
                    fuse-devel \
                    scitokens-cpp \
                    scitokens-cpp-devel

# python
RUN dnf install -y python3-devel \
                   python3.9-pip
RUN python3 -m pip install -U pip

# Rucio
#RUN pip3 install rucio-clients

# add others
RUN dnf install -y git cmake cmake3 make gcc gcc-c++ gdb
RUN dnf install -y autoconf automake libtool libasan
RUN dnf install -y vim sudo voms-clients-java

# gfal
#RUN dnf install -y gfal2-util-scripts gfal2-python3 gfal2-plugin-file gfal2-plugin-http python3-gfal2-util

RUN dnf update -y
RUN dnf clean all


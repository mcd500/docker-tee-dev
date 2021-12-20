FROM aistcpsec/tee-distro-dev:riscv-20.04 AS build
# TO trasioteam/riscv_toolchain:keystone

# Make sure the following command run as build-user
USER build-user

# for tzdata
ENV DEBIAN_FRONTEND=noninteractive
ENV USER_DIR=/home/user
# see http://192.168.100.100/rinkai/dockerfiles/-/jobs/5698
ENV FORCE_UNSAFE_CONFIGURE=1

WORKDIR $USER_DIR

# install keyedge
RUN mkdir -p ${USER_DIR}/.ssh && ssh-keyscan -H github.com >> ${USER_DIR}/.ssh/known_hosts
RUN git clone https://github.com/keystone-enclave/keyedge.git
WORKDIR $USER_DIR/keyedge
RUN rm -fr flatcc
RUN git clone https://github.com/dvidelabs/flatcc.git && cd flatcc && \
    git checkout 2abb8b5d12ef56cebeaa291d42832b5deb436783
RUN make

ENV KEYEDGE_DIR=${USER_DIR}/keyedge

# Install Keystone SDK
WORKDIR $USER_DIR
ARG VERSION=
RUN git clone https://github.com/keystone-enclave/keystone.git -b ${VERSION}

ENV KEYSTONE_DIR=$USER_DIR/keystone

WORKDIR $KEYSTONE_DIR

# This is for debugging purpose. This will show the output of the following command on console
ARG DEBUG_DATE=

# Run the fast-setup for keystone
RUN ./fast-setup.sh

WORKDIR $KEYSTONE_DIR

# Set the KEYSTONE_SDK_DIR and RISCV directories
ENV KEYSTONE_SDK_DIR=${KEYSTONE_DIR}/sdk/build64
ENV RISCV=${TOOLCHAIN_DIR}

# Increase the max edge calls
RUN sed -i 's/MAX_EDGE_CALL 10$/MAX_EDGE_CALL 1000/' ${KEYSTONE_DIR}/sdk/include/edge/edge_common.h

# Build the keystone sdk
RUN mkdir -p build && \
  cd build && \
  cmake .. && \
  make && \
  make image


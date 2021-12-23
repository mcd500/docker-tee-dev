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
ENV KEYEDGE_DIR=${USER_DIR}/keyedge
RUN mkdir -p ${USER_DIR}/.ssh && ssh-keyscan -H github.com >> ${USER_DIR}/.ssh/known_hosts
RUN git clone https://github.com/keystone-enclave/keyedge.git&& \
    git checkout 6e9a0c3940ce9ac994cd5b0fcdfd3f470fc949f1

WORKDIR $KEYEDGE_DIR
RUN sed -i 's,git@github.com:dvidelabs/flatcc.git,https://github.com/dvidelabs/flatcc.git,g' ${KEYEDGE_DIR}/.gitmodules
RUN git submodule sync --recursive
RUN git submodule update --init --recursive
RUN make


# Install Keystone SDK
WORKDIR $USER_DIR
ARG VERSION=
RUN git clone https://github.com/keystone-enclave/keystone.git -b ${VERSION}

ENV KEYSTONE_DIR=$USER_DIR/keystone
WORKDIR $KEYSTONE_DIR

# This is for debugging purpose. This will show the output of the following command on console
#ARG DEBUG_DATE=
#RUN echo ${DEBUG_DATE} > date

# Run the fast-setup for keystone
RUN ./fast-setup.sh

# Set the KEYSTONE_SDK_DIR and RISCV directories
# KEYSTONE_SDK_DIR is where it is installed
ENV KEYSTONE_SDK_DIR=${KEYSTONE_DIR}/sdk/build64
ENV RISCV=${TOOLCHAIN_DIR}

# Increase the max edge calls
RUN sed -i 's/MAX_EDGE_CALL 10$/MAX_EDGE_CALL 1000/' ${KEYSTONE_DIR}/sdk/include/edge/edge_common.h

# Build the keystone image for qemu
RUN mkdir -p build
WORKDIR $KEYSTONE_DIR/build
RUN cmake ..
RUN make
RUN make image

# Build the keystone sdk
WORKDIR $KEYSTONE_DIR/sdk
RUN mkdir -p build
WORKDIR $KEYSTONE_DIR/sdk/build
RUN cmake .. $SDK_FLAGS
RUN make
#RUN make image
RUN make install

# Install keystone-runime
RUN cd ${KEYSTONE_SDK_DIR} && \
  git clone https://github.com/keystone-enclave/keystone-runtime.git -b v1.0.0 runtime && \
  cd runtime && \
  touch .options_log && \
  make BITS=64 OPTIONS_FLAGS="-DUSE_FREEMEM"

# Set to user dir 
WORKDIR $USER_DIR
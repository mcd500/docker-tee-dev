FROM aistcpsec/tee-distro-dev:riscv-20.04 AS build
# TO trasioteam/riscv_toolchain:keystone

# for tzdata
ENV DEBIAN_FRONTEND=noninteractive
ENV USER_DIR=/home/user
# see http://192.168.100.100/rinkai/dockerfiles/-/jobs/5698
ENV FORCE_UNSAFE_CONFIGURE=1
WORKDIR $USER_DIR

ARG VERSION=v1.0.0
RUN git clone https://github.com/keystone-enclave/keystone -b ${VERSION}

ENV KEYSTONE_DIR=$USER_DIR/keystone
ENV RISCV=${KEYSTONE_DIR}/riscv64

# install keyedge
RUN mkdir -p ${USER_DIR}/.ssh && ssh-keyscan -H github.com >> ${USER_DIR}/.ssh/known_hosts
# RUN GIT_SSL_NO_VERIFY=1 git clone --recursive https://github.com/keystone-enclave/keyedge.git
RUN git clone https://github.com/keystone-enclave/keyedge.git
WORKDIR $USER_DIR/keyedge
RUN git checkout f9406aba2117147cc54462ede4766e26f028ced9
RUN git submodule sync --recursive
RUN git submodule update --init --recursive
RUN make

ENV KEYEDGE_DIR=${USER_DIR}/keyedge

# install keedger8r
#RUN GIT_SSL_NO_VERIFY=1 git clone https://192.168.100.100/rinkai/keedger8r && \
#  cd ${KEEDGER8R_DIR} && \
#  make
#ENV KEEDGER8R_DIR=${MAIN_DIR}/keedger8r
#ENV PATH=${KEEDGER8R_DIR}:${PATH}

# increase number of edge calls
RUN sed -i 's/MAX_EDGE_CALL 10$/MAX_EDGE_CALL 1000/' ${KEYSTONE_DIR}/sdk/include/edge/edge_common.h
RUN cd ${KEYSTONE_DIR}/sdk && \
  make -C build uninstall && \
  rm -rf build build64 && \
  mkdir -p build && \
  cd build && \
  cmake .. && \
  make && \
  # Keystone SDK has been installed at ${KEYSTONE_SDK_DIR}
  make install

RUN cd ${KEYSTONE_SDK_DIR} && \
  git clone https://github.com/keystone-enclave/keystone-runtime.git -b v1.0.0 runtime && \
  cd runtime && \
  touch .options_log && \
  make BITS=64 OPTIONS_FLAGS="-DUSE_FREEMEM"

# second build
#FROM aistcpsec/tee-distro-dev:riscv-20.04 AS build

#ENV MAIN_DIR=/home/main
#ENV RISCV=${MAIN_DIR}/riscv
#ENV PATH=$RISCV/bin:$PATH
## see http://192.168.100.100/rinkai/dockerfiles/-/jobs/5698
#WORKDIR $MAIN_DIR
#COPY --from=build ${RISCV} ${RISCV}

FROM aistcpsec/tee-distro-dev:riscv-20.04 AS build
# TO trasioteam/riscv_toolchain:keystone

# for tzdata
ENV DEBIAN_FRONTEND=noninteractive
ENV USER_DIR=/home/user
# see http://192.168.100.100/rinkai/dockerfiles/-/jobs/5698
ENV FORCE_UNSAFE_CONFIGURE=1
WORKDIR $USER_DIR

# install keyedge
RUN mkdir -p ${USER_DIR}/.ssh && ssh-keyscan -H github.com >> ${USER_DIR}/.ssh/known_hosts
# RUN GIT_SSL_NO_VERIFY=1 git clone --recursive https://github.com/keystone-enclave/keyedge.git
RUN git clone https://github.com/keystone-enclave/keyedge.git
WORKDIR $USER_DIR/keyedge
RUN rm -fr flatcc
RUN git clone https://github.com/dvidelabs/flatcc.git && cd flatcc && \
    git checkout 2abb8b5d12ef56cebeaa291d42832b5deb436783
#RUN git checkout f9406aba2117147cc54462ede4766e26f028ced9
RUN make

ENV KEYEDGE_DIR=${USER_DIR}/keyedge

# install keedger8r
#RUN GIT_SSL_NO_VERIFY=1 git clone https://192.168.100.100/rinkai/keedger8r && \
#  cd ${KEEDGER8R_DIR} && \
#  make
#ENV KEEDGER8R_DIR=${MAIN_DIR}/keedger8r
#ENV PATH=${KEEDGER8R_DIR}:${PATH}

WORKDIR $USER_DIR
ARG VERSION=
RUN git clone https://github.com/keystone-enclave/keystone -b ${VERSION}

ENV KEYSTONE_DIR=$USER_DIR/keystone
#ENV RISCV=${KEYSTONE_DIR}/riscv64

WORKDIR $KEYSTONE_DIR
# copying procedure from https://github.com/keystone-enclave/keystone/blob/v1.0.0/fast-setup.sh
# It is for improving git clone speed
RUN git config submodule.riscv-gnu-toolchain.update none

# shallow clone submodules ahead of time (Git must be > 2.11)
RUN if [ ! -e linux/.git ]; then; \
      git clone --shallow-since=2020-05-15 https://github.com/torvalds/linux.git linux; \
    fi
RUN if [ ! -e buildroot/.git ]; then; \
      git clone --shallow-since=2020-04-15 https://github.com/buildroot/buildroot.git buildroot; \
    fi
RUN if [ ! -e qemu/.git ]; then; \
      git clone --shallow-since=2020-11-15 https://github.com/qemu/qemu.git qemu; \
    fi
RUN git submodule sync --recursive
RUN git submodule update --init --recursive

# increase number of edge calls
ENV KEYSTONE_SDK_DIR=${KEYSTONE_DIR}/sdk
WORKDIR $KEYSTONE_SDK_DIR
RUN git checkout v1.0.0
RUN pwd; ls -l
RUN cd $USER_DIR; find . -name edge_common.h
RUN sed -i 's/MAX_EDGE_CALL 10$/MAX_EDGE_CALL 1000/' ${KEYSTONE_DIR}/sdk/include/edge/edge_common.h
RUN make -C build uninstall && \
  rm -rf build build64 && \
  mkdir -p build && \
  cd build && \
  cmake .. && \
  make && \
  # Keystone SDK has been installed at ${KEYSTONE_SDK_DIR}
  make install

RUN git clone https://github.com/keystone-enclave/keystone-runtime.git -b v1.0.0 runtime && \
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

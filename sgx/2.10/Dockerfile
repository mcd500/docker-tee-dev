FROM aistcpsec/tee-distro-dev:x64-20.04 as builder
# TO trasioteam2/intel_sgx:(2.8|2.10|2.11)

# This is to prevent waiting for key type when installing tzdata
ENV DEBIAN_FRONTEND=noninteractive
ENV USER_DIR=/home/user
ENV LINUX_SGX_DIR=${USER_DIR}/sgx
ARG DEBUG=1

# install intel sgx sdk

ENV SGX_INSTALL_DIR=/opt/intel
ENV SGX_SDK=${SDK_PACKAGE_ROOT_DIR}/sgxsdk

# see ${SGX_SDK}/environment
ENV PATH=${PATH}:${SGX_SDK}/bin:${SGX_SDK}/bin/x64
#ENV PKG_CONFIG_PATH=${SGX_SDK}/pkgconfig
ENV LD_LIBRARY_PATH=${SGX_SDK}/sdk_libs
WORKDIR ${USER_DIR}

# build Intel SGX SDK installer
ARG VERSION=
RUN echo ${VERSION}
RUN git clone https://github.com/intel/linux-sgx.git -b sgx_${VERSION}

WORKDIR ${USER_DIR}/linux-sgx
RUN ./download_prebuilt.sh
RUN pwd; ls -l; echo a
RUN cp external/toolset/ubuntu20.04/{as,ld,ld.gold,objdump} /usr/local/bin
#COPY tmp/external_link_${VERSION}.sh /tmp/external_link.sh
#RUN  /tmp/external_link.sh

RUN make sdk_install_pkg DEBUG=${DEBUG}

# install SGX SDK(use expect command)
COPY ./tmp/exp.sh /tmp/exp.sh
RUN /tmp/exp.sh ${LINUX_SGX_DIR}/linux/installer/bin/sgx_linux_x64_sdk_*.bin ${SDK_PACKAGE_ROOT_DIR}

# build the Intel(R) SGX PSW and its installer
# deb_psw_pkg includes `make psw`
# see Note) in https://github.com/intel/linux-sgx/tree/sgx_2.8#build-the-intelr-sgx-psw-and-intelr-sgx-psw-installer
ENV DEB_BUILD_OPTIONS="nostrip"
ENV SGX_PSW_INSTALLER_DIR=${LINUX_SGX_DIR}/linux/installer
RUN make deb_psw_pkg DEBUG=${DEBUG}

# Only with sdk binaries and no sources
FROM ubuntu:20.04 as slim

# for tzdata
ENV DEBIAN_FRONTEND=noninteractive
ENV USER_DIR=/home/user
ENV LINUX_SGX_DIR=${USER_DIR}/sgx
ENV SGX_PSW_INSTALLER_DIR=${LINUX_SGX_DIR}/linux/installer
ENV SGX_INSTALL_DIR=/opt/intel
ENV SGX_SDK=${SGX_INSTALL_DIR}/sgxsdk

# see ${SGX_SDK}/environment
ENV PATH=${PATH}:${SGX_SDK}/bin:${SGX_SDK}/bin/x64
COPY --from=builder ${SGX_INSTALL_DIR} ${SGX_INSTALL_DIR}
COPY --from=builder ${SGX_PSW_INSTALLER_DIR} ${SGX_PSW_INSTALLER_DIR}

# install *.deb in PSW except sgx-dcap-pccs because this package requires npm and nodejs, which cannot be installed via apt-get
RUN rm ${SGX_PSW_INSTALLER_DIR}/deb/*/sgx-dcap-pccs*.deb && \
  dpkg -i ${SGX_PSW_INSTALLER_DIR}/deb/*/*.deb

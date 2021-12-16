FROM aistcpsec/tee-distro-dev:x64-20.04 as builder
# TO trasioteam2/intel_sgx:(2.8|2.10|2.11)

# This is to prevent waiting for key type when installing tzdata
ENV DEBIAN_FRONTEND=noninteractive
ENV USER_DIR=/home/user
ENV LINUX_SGX_DIR=${USER_DIR}/sgx
ARG DEBUG=1

# Set the required environmental variables.
ENV SGX_INSTALL_DIR=/opt/intel
ENV SGX_SDK=${SGX_INSTALL_DIR}/sgxsdk
ENV PATH=${PATH}:${SGX_SDK}/bin:${SGX_SDK}/bin/x64
ENV PKG_CONFIG_PATH=${SGX_SDK}/pkgconfig
ENV LD_LIBRARY_PATH=${SGX_SDK}/sdk_libs

# Create and change to ${LINUX_SGX_DIR} 
WORKDIR ${LINUX_SGX_DIR}

# Print the version from the command-line args
ARG VERSION=
RUN echo ${VERSION}

# Clone the Intel SGX repo
RUN git clone https://github.com/intel/linux-sgx.git -b sgx_${VERSION}

# Set the sgx base dir
ENV SGX_DIR=${LINUX_SGX_DIR}/linux-sgx
WORKDIR ${SGX_DIR}

# Download the prebuilt binaries for intel sgx
RUN ./download_prebuilt.sh
RUN cd external/toolset/ubuntu20.04/ && cp as ld ld.gold objdump /usr/local/bin
RUN cd ${SGX_DIR}

# Make the intel sdk package
RUN make sdk_install_pkg DEBUG=${DEBUG}

# Make a script to install the intel sgx in SGX_INSTALL_DIR 
RUN echo '#!/usr/bin/expect -f \n\
set install_bin [lindex $argv 0]; \n\
set output_dir [lindex $argv 1]; \n\
spawn $install_bin \n\
expect "Do you want to install in current directory?" \n\
send "no\r" \n\
expect "Please input the directory which you want to install in" \n\
send "$output_dir\r" \n\
expect eof' > exp.sh

# Set the executable permissions for the script
RUN chmod u+x exp.sh

# Execute the script
RUN ./exp.sh ${SGX_DIR}/linux/installer/bin/sgx_linux_x64_sdk_2.10.100.2.bin ${SGX_INSTALL_DIR}

# Print the contents for confirmation
RUN ls -l ${SGX_INSTALL_DIR}
RUN ls -l ${SGX_DIR}

# build the Intel(R) SGX PSW and its installer
# deb_psw_pkg includes `make psw`
# see Note) in https://github.com/intel/linux-sgx/tree/sgx_2.8#build-the-intelr-sgx-psw-and-intelr-sgx-psw-installer
ENV DEB_BUILD_OPTIONS="nostrip"
ENV SGX_PSW_INSTALLER_DIR=${SGX_DIR}/linux/installer
RUN make deb_psw_pkg DEBUG=${DEBUG}

# Only with sdk binaries and no sources
FROM ubuntu:20.04 as slim

# for tzdata
ENV DEBIAN_FRONTEND=noninteractive
ENV USER_DIR=/home/user
ENV LINUX_SGX_DIR=${USER_DIR}/sgx
ENV SGX_DIR=${LINUX_SGX_DIR}/linux-sgx
ENV SGX_PSW_INSTALLER_DIR=${SGX_DIR}/linux/installer
ENV SGX_INSTALL_DIR=/opt/intel
ENV SGX_SDK=${SGX_INSTALL_DIR}/sgxsdk

# see ${SGX_SDK}/environment
ENV PATH=${PATH}:${SGX_SDK}/bin:${SGX_SDK}/bin/x64
COPY --from=builder ${SGX_INSTALL_DIR} ${SGX_INSTALL_DIR}
COPY --from=builder ${SGX_PSW_INSTALLER_DIR} ${SGX_PSW_INSTALLER_DIR}

# This must executed before any other install or purge, error will occur
RUN apt-get update

# Install the required packages
RUN apt-get install -y libcurl4 libprotobuf17

# install *.deb in PSW except sgx-dcap-pccs because this package requires npm and nodejs, which cannot be installed via apt-get
RUN rm ${SGX_PSW_INSTALLER_DIR}/deb/*/sgx-dcap-pccs*.deb && \
  dpkg -i ${SGX_PSW_INSTALLER_DIR}/deb/*/*.deb

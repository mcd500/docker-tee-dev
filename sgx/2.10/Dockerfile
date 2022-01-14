FROM aistcpsec/tee-distro-dev:x64-20.04 as builder
# TO aistcpsec/tee-dev:sgx-2.10

# Make sure the following command run as build-user
USER build-user

# This is to prevent waiting for key type when installing tzdata
ENV DEBIAN_FRONTEND=noninteractive
ENV USER_DIR=/home/user

# Set the required environmental variables.
ENV OPT_INTEL=/opt/intel
ENV SDK_INSTALL_DIR=${OPT_INTEL}/sgxsdk
ENV PATH=${PATH}:${SDK_INSTALL_DIR}/bin:${SDK_INSTALL_DIR}/bin/x64
ENV PKG_CONFIG_PATH=${SDK_INSTALL_DIR}/pkgconfig
ENV LD_LIBRARY_PATH=${SDK_INSTALL_DIR}/sdk_libs
ARG DEBUG=1

# Print the version from the command-line args
ARG VERSION=
RUN echo ${VERSION}

# Where to clone
WORKDIR ${USER_DIR}

# Clone the Intel SGX repo
RUN git clone https://github.com/intel/linux-sgx.git -b sgx_${VERSION}

# Set the sgx base dir
ENV CLONE_DIR=${USER_DIR}/linux-sgx
WORKDIR ${CLONE_DIR}

# Download the prebuilt binaries for intel sgx
RUN ./download_prebuilt.sh
RUN cd external/toolset/ubuntu20.04/ && sudo cp as ld ld.gold objdump /usr/local/bin

# Make the intel sdk package
RUN make sdk_install_pkg DEBUG=${DEBUG}

# Make a script to install the intel sgx in OPT_INTEL
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
RUN sudo mkdir -p ${OPT_INTEL}
RUN sudo ./exp.sh ${CLONE_DIR}/linux/installer/bin/sgx_linux_x64_sdk_2.10.100.2.bin ${OPT_INTEL}

# Print the contents for confirmation, debug purpose
RUN ls -l ${CLONE_DIR}
RUN ls -l ${OPT_INTEL}

# build the Intel(R) SGX PSW and its installer
# deb_psw_pkg includes `make psw`
# see Note) in https://github.com/intel/linux-sgx/tree/sgx_2.8#build-the-intelr-sgx-psw-and-intelr-sgx-psw-installer
ENV DEB_BUILD_OPTIONS="nostrip"
ENV SGX_PSW_INSTALLER_DIR=${CLONE_DIR}/linux/installer
RUN make deb_psw_pkg DEBUG=${DEBUG}


# install *.deb in PSW except sgx-dcap-pccs because this package requires npm and nodejs, which cannot be installed via apt-get
RUN rm ${SGX_PSW_INSTALLER_DIR}/deb/*/sgx-dcap-pccs*.deb && \
  sudo dpkg -i ${SGX_PSW_INSTALLER_DIR}/deb/*/*.deb

# Only with sdk binaries and no sources
FROM aistcpsec/tee-distro-dev:x64-20.04 as slim

# Make sure the following command run as build-user
USER build-user

# for tzdata
ENV DEBIAN_FRONTEND=noninteractive
ENV USER_DIR=/home/user

ENV OPT_INTEL=/opt/intel
ENV SDK_INSTALL_DIR=${OPT_INTEL}/sgxsdk
ENV SGX_SDK=${SDK_INSTALL_DIR}

# see ${SDK_INSTALL_DIR}/environment
ENV PATH=${PATH}:${SDK_INSTALL_DIR}/bin:${SDK_INSTALL_DIR}/bin/x64

# copy only installed sgx binaries
COPY --from=builder ${OPT_INTEL} ${OPT_INTEL}

# Set to user dir 
WORKDIR $USER_DIR

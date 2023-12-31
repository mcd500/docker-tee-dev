FROM aistcpsec/tee-distro-dev:arm64-20.04 as builder
# TO aistcpsec/tee-dev:optee-3.10.0_rpi3

# Make sure the following command run as build-user
USER build-user

# Set the required env variables
ENV USER_DIR=/home/user
ENV OPTEE_DIR=${USER_DIR}/optee
#ENV FORCE_UNSAFE_CONFIGURE=1

RUN mkdir -p ${OPTEE_DIR}
WORKDIR ${OPTEE_DIR}

# Install Android repo
RUN sudo git config --global user.name "dummy" && \
  sudo git config --global user.email "dummy@gmail.com" && \
  sudo git config --global color.ui false && \
  mkdir ${USER_DIR}/bin && \
  curl https://storage.googleapis.com/git-repo-downloads/repo > ${USER_DIR}/bin/repo && \
  chmod a+x ${USER_DIR}/bin/repo
ENV PATH=${USER_DIR}/bin:${PATH}

# To get the build args version information
ARG VERSION=

# Get the source code for optee

RUN repo init -u https://github.com/OP-TEE/manifest.git -m rpi3.xml -b ${VERSION}
RUN repo sync -j4 --no-clone-bundle

RUN sed -i '/MBEDTLS_ECDSA_C/a#define MBEDTLS_HMAC_DRBG_C' optee_os/lib/libmbedtls/include/mbedtls_config_uta.h
RUN sed -i '/MBEDTLS_ECDSA_C/a#define MBEDTLS_ECDSA_DETERMINISTIC' optee_os/lib/libmbedtls/include/mbedtls_config_uta.h

# To print the output of following command
#ARG DEBUG_DATE=
#RUN echo ${DEBUG_DATE} > date

# Build optee
ENV OPT_ARM_TC=/opt/arm-tc
ENV TOOLCHAIN_ROOT=${OPT_ARM_TC}
WORKDIR ${OPTEE_DIR}/build
RUN ln -s ${TOOLCHAIN_ROOT} ${OPTEE_DIR}/toolchains
RUN make TOOLCHAIN_ROOT=${OPT_ARM_TC} -j`nproc`

############################################################################
# Second build to copy only optee-dir
FROM aistcpsec/tee-distro-dev:arm64-20.04 as slim

# Make sure the following command run as build-user
USER build-user

# set the env variables
ENV OPTEE_DIR=${USER_DIR}/optee

#copy only the required dir
COPY --from=builder ${OPTEE_DIR}/optee_os/out ${OPTEE_DIR}/optee_os/out
COPY --from=builder ${OPTEE_DIR}/build ${OPTEE_DIR}/build
COPY --from=builder ${OPTEE_DIR}/u-boot ${OPTEE_DIR}/u-boot
COPY --from=builder ${OPTEE_DIR}/linux/arch ${OPTEE_DIR}/linux/arch
COPY --from=builder ${OPTEE_DIR}/out ${OPTEE_DIR}/out
COPY --from=builder ${OPTEE_DIR}/out-br ${OPTEE_DIR}/out-br
COPY --from=builder ${OPTEE_DIR}/optee_client/public ${OPTEE_DIR}/optee_client/public
COPY --from=builder ${OPTEE_DIR}/trusted-firmware-a/build ${OPTEE_DIR}/trusted-firmware-a/build
RUN sudo ln -s ${TOOLCHAIN_DIR} ${OPTEE_DIR}/toolchains

# Set to user dir
WORKDIR $USER_DIR

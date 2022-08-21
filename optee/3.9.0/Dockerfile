FROM aistcpsec/tee-distro-dev:arm64-20.04 as builder
# TO aistcpsec/tee-dev:optee-3.9.0

# Make sure the following command run as build-user
USER build-user

# Set the required env variables
ENV USER_DIR=/home/user
#ENV FORCE_UNSAFE_CONFIGURE=1

WORKDIR ${USER_DIR}

# Install Android repo
RUN git config --global user.name "dummy" && \
  git config --global user.email "dummy@gmail.com" && \
  git config --global color.ui false && \
  mkdir ${USER_DIR}/bin && \
  curl https://storage.googleapis.com/git-repo-downloads/repo > ${USER_DIR}/bin/repo && \
  chmod a+x ${USER_DIR}/bin/repo
ENV PATH=${PATH}:${USER_DIR}/bin

# This is for debugging purpose. This will show the output of the following command on console
#ARG DEBUG_DATE
#RUN echo ${DEBUG_DATE} > date

# For fetching build-optee-repo.git
ARG CI_JOB_TOKEN
RUN git config --global user.name gitlab-ci-token
RUN git config --global http.sslVerify false
RUN git config --global credential.helper 'store --file ~/.git-credentials'
RUN echo https://gitlab-ci-token:${CI_JOB_TOKEN}@192.168.100.100:443 >> ~/.git-credentials
RUN echo https://gitlab-ci-token:${CI_JOB_TOKEN}@192.168.100.100 >> ~/.git-credentials

RUN cat ~/.gitconfig
RUN cat ~/.git-credentials

# Start optee 
ENV OPTEE_DIR=${USER_DIR}/optee
#RUN mkdir -p ${OPTEE_DIR}
WORKDIR ${OPTEE_DIR}

# To get the build args version information
ARG VERSION

# Get the source code for optee
RUN repo --trace init --depth=1 -u https://github.com/OP-TEE/manifest.git -m qemu_v8.xml -b ${VERSION}
RUN repo sync -j4 --no-clone-bundle --no-tags 1> /dev/null

# Customize optee, enable some crypto algorithms
RUN sed -i '/MBEDTLS_ECDSA_C/a#define MBEDTLS_HMAC_DRBG_C' optee_os/lib/libmbedtls/include/mbedtls_config_uta.h
RUN sed -i '/MBEDTLS_ECDSA_C/a#define MBEDTLS_ECDSA_DETERMINISTIC' optee_os/lib/libmbedtls/include/mbedtls_config_uta.h

# Build optee
ENV OPT_ARM_TC=/opt/arm-tc
ENV TOOLCHAIN_ROOT=${OPT_ARM_TC}
WORKDIR ${OPTEE_DIR}/build
RUN ln -s ${TOOLCHAIN_ROOT} ${OPTEE_DIR}/toolchains
RUN make TOOLCHAIN_ROOT=${OPT_ARM_TC} -j`nproc`

RUN rm -f ~/.git-credentials

############################################################################
# Second build to copy only optee-dir
FROM aistcpsec/tee-distro-dev:arm64-20.04 as slim

# Make sure the following command run as build-user
USER build-user

# set the env variables
ENV OPTEE_DIR=${USER_DIR}/optee

#copy only the required dir
COPY --from=builder ${OPTEE_DIR}/optee_os/out ${OPTEE_DIR}/optee_os/out
COPY --from=builder ${OPTEE_DIR}/build/zynqmp.mk ${OPTEE_DIR}/build/zynqmp.mk
COPY --from=builder ${OPTEE_DIR}/edk2/Build ${OPTEE_DIR}/edk2/Build
COPY --from=builder ${OPTEE_DIR}/edk2/NetworkPkg ${OPTEE_DIR}/edk2/NetworkPkg
COPY --from=builder ${OPTEE_DIR}/linux/arch ${OPTEE_DIR}/linux/arch
COPY --from=builder ${OPTEE_DIR}/out ${OPTEE_DIR}/out
COPY --from=builder ${OPTEE_DIR}/out-br ${OPTEE_DIR}/out-br
COPY --from=builder ${OPTEE_DIR}/qemu/aarch64-softmmu ${OPTEE_DIR}/qemu/aarch64-softmmu
COPY --from=builder ${OPTEE_DIR}/qemu/pc-bios ${OPTEE_DIR}/qemu/pc-bios
COPY --from=builder ${OPTEE_DIR}/optee_client/public ${OPTEE_DIR}/optee_client/public
COPY --from=builder ${OPTEE_DIR}/trusted-firmware-a/build ${OPTEE_DIR}/trusted-firmware-a/build
RUN sudo ln -s ${TOOLCHAIN_DIR} ${OPTEE_DIR}/toolchains

# Set to user dir
WORKDIR $USER_DIR

FROM aistcpsec/tee-distro-dev:arm64-20.04 as builder
# TO aistcpsec/tee-dev:optee-3.10.0

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
RUN repo init -u https://github.com/OP-TEE/manifest.git -m qemu_v8.xml -b ${VERSION}
RUN repo sync -j4 --no-clone-bundle

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

#copy only built opteedir
COPY --from=builder ${OPTEE_DIR} ${OPTEE_DIR}

# Set to user dir 
WORKDIR $USER_DIR

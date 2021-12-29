FROM aistcpsec/tee-distro-dev:arm64-20.04 as builder

# Make sure the following command run as build-user
USER build-user

# Set the required env variables
ENV USER_DIR=/home/user
ENV OPTEE_DIR=${USER_DIR}/optee
#ENV FORCE_UNSAFE_CONFIGURE=1

# Install Android repo
RUN git config --global user.name "dummy" && \
  git config --global user.email "dummy@gmail.com" && \
  git config --global color.ui false && \
  mkdir ${USER_DIR}/bin && \
  curl https://storage.googleapis.com/git-repo-downloads/repo > ${USER_DIR}/bin/repo && \
  chmod a+x ${USER_DIR}/bin/repo

# To get the build args version information
ARG VERSION=


# For fetching build-optee-repo.git
RUN git config --global credential.helper 'store --file ~/.git-credentials' && \
  git config --global user.name gitlab-ci-token && \
  git config --global http.sslVerify false

# Build optee
ENV OPT_ARM_TC=/opt/arm-tc
ENV TOOLCHAIN_ROOT=${OPT_ARM_TC}

# downlaod and build
RUN \
  CACHE_TAG=0; \
  cd ${MAIN_DIR}; \
  mkdir -p ${OPTEE_DIR} && cd ${OPTEE_DIR} && \
  PATH=${PATH}:~/bin && \
  repo init --depth=1 -u https://192.168.100.100/rinkai/build-optee-repo.git -m qemu_v8-teep.xml 1> /dev/null && \
  repo sync -j4 -f --force-sync --no-clone-bundle --no-tags 1> /dev/null && \
  cd build; \
  ln -s ${TOOLCHAIN_ROOT} ${OPTEE_DIR}/toolchains && \
  make TOOLCHAIN_ROOT=${OPT_ARM_TC} -j`nproc` 1> /dev/null

RUN rm -f ~/.git-credentials

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
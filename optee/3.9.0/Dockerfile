FROM aistcpsec/tee-distro-dev:arm64-20.04 as builder

# Make sure the following command run as build-user
USER build-user

# Set the required env variables
ENV USER_DIR=/home/user
ENV OPTEE_DIR=${USER_DIR}/optee
#ENV FORCE_UNSAFE_CONFIGURE=1

WORKDIR $USER_DIR

# Install Android repo
RUN git config --global user.name "dummy" && \
  git config --global user.email "dummy@gmail.com" && \
  git config --global color.ui false && \
  mkdir ${USER_DIR}/bin && \
  curl https://storage.googleapis.com/git-repo-downloads/repo > ${USER_DIR}/bin/repo && \
  chmod a+x ${USER_DIR}/bin/repo
ENV PATH=${PATH}:${USER_DIR}/bin

# To get the build args version information
ARG VERSION=

# This is for debugging purpose. This will show the output of the following command on console
ARG DEBUG_DATE=
RUN echo ${DEBUG_DATE} > date

# For fetching build-optee-repo.git
ARG CI_JOB_TOKEN=
RUN git config --global user.name gitlab-ci-token
RUN git config --global http.sslVerify false
RUN git config --global credential.helper 'store --file ~/.git-credentials'
RUN echo https://gitlab-ci-token:${CI_JOB_TOKEN}@192.168.100.100:443 >> ~/.git-credentials
RUN echo https://gitlab-ci-token:${CI_JOB_TOKEN}@192.168.100.100 >> ~/.git-credentials

RUN cat ~/.gitconfig
RUN cat ~/.git-credentials

# Build optee
ENV OPT_ARM_TC=/opt/arm-tc
ENV TOOLCHAIN_ROOT=${OPT_ARM_TC}

# downlaod and build
RUN \
  CACHE_TAG=0; \
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

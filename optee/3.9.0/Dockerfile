FROM aistcpsec/tee-distro-dev:arm64-20.04 as builder

# Set the required env variables
ENV USER_DIR=/home/user
ENV OPTEE_DIR=${USER_DIR}/optee
ENV FORCE_UNSAFE_CONFIGURE=1

ARG VERSION=

# Install Android repo
RUN git config --global user.name "dummy" && \
  git config --global user.email "dummy@gmail.com" && \
  git config --global color.ui false && \
  mkdir ~/bin && \
  curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo && \
  chmod a+x ~/bin/repo

# Get the source code for optee
RUN mkdir -p ${OPTEE_DIR} && cd ${OPTEE_DIR} && \
  ~/bin/repo init -u https://github.com/OP-TEE/manifest.git -m qemu_v8.xml -b ${VERSION} && \
  ~/bin/repo sync -j4 --no-clone-bundle && \
  ln -s ${TOOLCHAIN_DIR} ${OPTEE_DIR}/toolchains

WORKDIR ${OPTEE_DIR}/build

# To print the output of following command
ARG DEBUG_DATE=

# Build optee
RUN make -j4

# Second build to copy only optee-dir
FROM aistcpsec/tee-distro-dev:arm64-20.04 as slim

# set the env variables
ENV OPTEE_DIR=${USER_DIR}/optee



#copy only built opteedir
COPY --from=builder ${OPTEE_DIR} ${OPTEE_DIR}
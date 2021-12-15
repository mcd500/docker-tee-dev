FROM aistcpsec/tee-distro-dev:arm64-20.04 as builder

ARG USER_DIR=/home/user
ARG VERSION=
ENV OPTEE_DIR=${USER_DIR}/optee
ENV FORCE_UNSAFE_CONFIGURE=1

# install repo command
RUN git config --global user.name "dummy" && \
  git config --global user.email "dummy@gmail.com" && \
  git config --global color.ui false && \
  mkdir ~/bin && \
  curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo && \
  chmod a+x ~/bin/repo

# download
RUN mkdir -p ${OPTEE_DIR} && cd ${OPTEE_DIR} && \
  ~/bin/repo init -u https://github.com/OP-TEE/manifest.git -m qemu_v8.xml -b ${VERSION} && \
  ~/bin/repo sync -j4 --no-clone-bundle && \
  ln -s ${TOOLCHAIN_DIR} ${OPTEE_DIR}/toolchains

WORKDIR ${OPTEE_DIR}/build
RUN make

FROM aistcpsec/tee-distro-dev:arm64-20.04 as slim
#copy only built opteedir

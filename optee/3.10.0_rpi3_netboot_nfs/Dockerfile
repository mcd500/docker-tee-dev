FROM aistcpsec/tee-distro-dev:rootfs-arm64-ubuntu-20.04-tar as builder

############################################################################
# Second build to copy the rootfs tar file
FROM aistcpsec/tee-dev:optee-3.10.0_rpi3 as slim

# Create a target directory to perform the operations
ENV TARGET_DIR=${USER_DIR}/target
RUN mkdir -p ${TARGET_DIR}

# Create a rootfs extraction directory to extract and zip it again
ENV ROOTFS_EXT_DIR=${TARGET_DIR}/arm64-20.04-rootfs
RUN mkdir -p ${ROOTFS_EXT_DIR}

# Copy the Rootfs tar file from the builder
COPY --from=builder /arm64-20.04-rootfs.tar.xz ${TARGET_DIR}/

# Copy the contents from the optee rootfs cpio file and copy to target directory
RUN gunzip -cd ${OPTEE_DIR}/out-br/images/rootfs.cpio.gz | cpio -D ${TARGET_DIR} -idmv \
  "usr/sbin/tee-supplicant" \
  "usr/lib/libteec.so.1.0.0" \
  "etc/init.d/S30optee" \
  "lib/optee_armtz/*"

WORKDIR ${TARGET_DIR}

RUN tar -xvf arm64-20.04-rootfs.tar.xz -C ${ROOTFS_EXT_DIR}
RUN cp etc/init.d/S30optee ${ROOTFS_EXT_DIR}/etc/init.d/ && \
    cp -r lib/optee_armtz/ ${ROOTFS_EXT_DIR}/lib/ && \
    cp usr/lib/libteec.so.1.0.0 ${ROOTFS_EXT_DIR}/usr/lib/ && \
    cp usr/sbin/tee-supplicant ${ROOTFS_EXT_DIR}/usr/sbin/

RUN tar -cvf ${USER_DIR}/arm64-20.04-rootfs.tar.xz ${ROOTFS_EXT_DIR}

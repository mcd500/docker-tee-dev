FROM aistcpsec/tee-dev:optee-3.10.0_rpi3
# TO aistcpsec/tee-dev:optee-3.10.0_rpi3_netboot_bootloader

# Make sure the following command run as build-user
USER build-user

RUN sudo apt-get update && \
  sudo apt-get install -y dosfstools

ENV MAIN_DIR=/home/user
ENV BOOT_DIR=${MAIN_DIR}/boot
ENV ROOTFS_ARCHIVE=${OPTEE_DIR}/out-br/images/rootfs.cpio.gz
ENV BOOT_IMG_PATH=${MAIN_DIR}/boot.img

# Update the uboot.env configuration to use NFS boot
ENV UBOOT_ENV_FILE=${OPTEE_DIR}/build/rpi3/firmware/uboot.env.txt

# Update the uboot.env.txt file with the actual values
RUN sed -i 's/gatewayip=192.168.1.1/gatewayip=192.168.100.1/g' ${UBOOT_ENV_FILE} && \
    sed -i 's/nfsserverip=192.168.1.100/nfsserverip=192.168.100.117/g' ${UBOOT_ENV_FILE} && \
    sed -i 's#nfspath=/srv/nfs/rpi#nfspath=/home/aist/nfs#g' ${UBOOT_ENV_FILE} && \
    sed -i 's/bootcmd=run mmcboot/bootcmd=run nfsboot/g' ${UBOOT_ENV_FILE} && \
    sed -i 's%set_bootargs_nfs=.*%set_bootargs_nfs=setenv bootargs \$\{bootargs\} root=/dev/nfs rw noinitrd rootfstype=nfs nfsroot=${nfsserverip}:${nfspath},udp,vers=3 ip=dhcp nfsrootdebug%g' ${UBOOT_ENV_FILE}

# Regenerate the uboot.env
RUN cd $OPTEE_DIR/build && \
    make u-boot-env-clean && \
    make u-boot-env


# create boot.img in ${BOOT_IMG_PATH}
RUN gunzip -cd ${ROOTFS_ARCHIVE} | cpio -idmv "boot/*" && \
  cp $OPTEE_DIR/out/uboot.env ${BOOT_DIR} && \
  dd if=/dev/zero of=${BOOT_IMG_PATH} bs=32M count=1 && \
  mkfs.vfat -F16 -n BOOT ${BOOT_IMG_PATH} && \
  find ${BOOT_DIR} -type f -exec basename {} \; | xargs -I{} mcopy -v -i ${BOOT_IMG_PATH} boot/{} ::{}

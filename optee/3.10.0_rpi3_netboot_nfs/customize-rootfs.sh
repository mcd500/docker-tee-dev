#!/bin/bash -xue

TARGET_DIR=/home/user/target
ROOTFS_EXT_DIR=${TARGET_DIR}/arm64-20.04-rootfs

# Copying files from host directory inside rootfs
cp /mnt/tee-supplicant.service ${ROOTFS_EXT_DIR}/etc/systemd/system/
chmod 644 ${ROOTFS_EXT_DIR}/etc/systemd/system/tee-supplicant.service

# Update lib cache for installed optee library
chroot ${ROOTFS_EXT_DIR} /bin/bash -c '
ldconfig /usr/lib
'
chroot ${ROOTFS_EXT_DIR} /bin/bash -c 'apt-get update && apt-get install -y npm'
chroot ${ROOTFS_EXT_DIR} /bin/bash -c 'curl https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash'
chroot ${ROOTFS_EXT_DIR} /bin/bash -c 'source $HOME/.nvm/nvm.sh && nvm install --lts && nvm use --lts'

# Booting tee-supplicant on power
chroot ${ROOTFS_EXT_DIR} /bin/bash -c '
systemctl enable tee-supplicant.service
'

# Update rootfs tar file
cd ${TARGET_DIR}
tar -cJf arm64-20.04-rootfs-optee.tar.xz --exclude="dev,proc,sys" arm64-20.04-rootfs && sudo mv arm64-20.04-rootfs-optee.tar.xz /

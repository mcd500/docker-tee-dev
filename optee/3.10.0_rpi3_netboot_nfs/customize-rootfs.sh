#!/bin/bash -xue

# Copying files from host directory inside rootfs
sudo cp /mnt/tee-supplicant.service /etc/systemd/system/
sudo chmod 644 ${ROOTFS_EXT_DIR}/etc/systemd/system/tee-supplicant.service

# For optee library
sudo ldconfig /usr/lib

# Booting tee-supplicant on power
sudo systemctl enable tee-supplicant.service

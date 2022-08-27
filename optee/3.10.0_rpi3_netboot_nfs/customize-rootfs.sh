#!/bin/bash -xue

# For optee library
sudo ldconfig /usr/lib

# Booting tee-supplicant on power
sudo systemctl enable tee-supplicant.service

#!/bin/bash

set -ouex pipefail

# Enable Copr support
dnf5 install -y dnf5-plugins

# Remove KDE Entirely
dnf5 remove -y plasma* kde* kf5* kf6* libwayland-client libX11
dnf5 autoremove -y

# Install wireless support
dnf5 install -y NetworkManager-wifi NetworkManager-wwan wpa_supplicant wireless-regdb NetworkManager-tui

# Install linux-firmware
dnf5 install -y linux-firmware kmod-nvidia ublue-os-nvidia-addons nvidia-driver nvidia-settings nvidia-gpu-firmware

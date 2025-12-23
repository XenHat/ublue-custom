#!/bin/bash

set -ouex pipefail

# Enable Copr support
dnf5 install -y dnf5-plugins

# Remove KDE Entirely
dnf5 remove -y plasma* kde* kf5* kf6*
# not stable yet, this removes too much
# dnf5 remove -y libwayland-client libX11
dnf5 autoremove -y

# Install wireless support
dnf5 install -y NetworkManager-wifi NetworkManager-wwan wpa_supplicant wireless-regdb NetworkManager-tui

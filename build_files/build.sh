#!/bin/bash

set -ouex pipefail

# Enable Copr support
dnf5 install -y dnf5-plugins

# Add more repositories
dnf5 config-manager addrepo --from-repofile=https://download.opensuse.org/repositories/home:/mkittler/Fedora_43/home:mkittler.repo

# Remove KDE Entirely
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
  --mount=type=cache,dst=/var/cache \
  --mount=type=cache,dst=/var/log \
  --mount=type=tmpfs,dst=/tmp \
  dnf5 remove -y plasma* kde* kf5* kf6* libwayland-client libx11 &&
  dnf5 autoremove -y

# Install wireless support
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
  --mount=type=cache,dst=/var/cache \
  --mount=type=cache,dst=/var/log \
  --mount=type=tmpfs,dst=/tmp \
  dnf5 install -y NetworkManager-wifi NetworkManager-wwan wpa_supplicant wireless-regdb NetworkManager-tui

# Install linux-firmware
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
  --mount=type=cache,dst=/var/cache \
  --mount=type=cache,dst=/var/log \
  --mount=type=tmpfs,dst=/tmp \
  dnf5 install -y linux-firmware &&
  dnf5 install -y kmod-nvidia ublue-os-nvidia-addons nvidia-driver nvidia-settings nvidia-gpu-firmware

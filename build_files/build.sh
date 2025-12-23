#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# this installs a package from fedora repos
dnf5 install -y tmux

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket

### Packages I use daily
dnf5 install -y neovim keepassxc flatpak zsh ImageMagick btop syncthing shellcheck
dnf5 -y copr enable scottames/ghostty
dnf5 install -y ghostty
dnf5 install -y ufw

# syncthingtray
dnf5 config-manager addrepo --from-repofile=https://download.opensuse.org/repositories/home:/mkittler/Fedora_43/home:mkittler.repo

# Dank Material Shell
dnf5 install -y niri
dnf5 -y copr enable errornointernet/quickshell
dnf5 -y install quickshell

# Gaming
dnf5 -y install gamemode

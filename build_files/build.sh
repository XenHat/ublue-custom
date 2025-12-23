#!/bin/bash

set -ouex pipefail

### Install packages
dnf5 install -y tmux
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

# systemctl enable podman.socket

## Repositories
dnf5 -y copr enable errornointernet/quickshell
dnf5 -y copr enable avengemedia/dms
dnf5 -y copr enable scottames/ghostty
dnf5 -y copr enable dejan/lazygit
dnf5 config-manager addrepo --from-repofile=https://download.opensuse.org/repositories/home:/mkittler/Fedora_43/home:mkittler.repo

# Remove KDE Entirely
dnf5 remove -y plasma* kde* kf5* kf6*
dnf5 install -y greetd dms-greeter

## Packages I use daily
dnf5 install -y neovim keepassxc flatpak zsh
dnf5 install -y ImageMagick btop syncthing shellcheck
dnf5 install -y NetworkManager-tui
dnf5 install -y ghostty
dnf5 install -y lazygit
dnf5 install -y clang lld bolt mold llvm-cmake-utils polly
dnf5 install -y syncthingtray
dnf5 install -y dms matugen niri quickshell
dnf5 -y install gamemode

dnf5 autoremove -y
## Configuration
echo '[terminal]
vt = 7
[default_session]
command = "dms-greeter --command niri"
user = "_greetd"' >/etc/greetd/config.toml

systemctl disable gdm lightdm sddm
systemctl enable greetd
# Disable COPRs so they don't end up enabled on the final image:
dnf5 -y copr disable errornointernet/quickshell
dnf5 -y copr disable avengemedia/dms
dnf5 -y copr disable scottames/ghostty
dnf5 -y copr disable dejan/lazygit

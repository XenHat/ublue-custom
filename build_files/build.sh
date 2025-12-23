#!/bin/bash

set -ouex pipefail

# Add COPRs
dnf5 -y copr enable errornointernet/quickshell
dnf5 -y copr enable avengemedia/dms
dnf5 -y copr enable scottames/ghostty
dnf5 -y copr enable dejan/lazygit
dnf5 config-manager addrepo --from-repofile=https://download.opensuse.org/repositories/home:/mkittler/Fedora_43/home:mkittler.repo # syncthingtray

# Login Manager
dnf5 install -y greetd dms-greeter
# Add required user for the login manager
useradd --system --no-create-home --shell /bin/false _greetd
mkdir /var/cache/dms-greeter
systemctl disable gdm lightdm sddm
systemctl enable greetd

# Personal packages
dnf5 install -y tmux neovim keepassxc flatpak zsh btop ghostty lazygit \
  ImageMagick syncthing shellcheck gamemode \
  syncthing syncthingtray \
  dms matugen niri quickshell xwayland-satellite

# Disable COPRs so they don't end up enabled on the final image:
dnf5 -y copr disable errornointernet/quickshell
dnf5 -y copr disable avengemedia/dms
dnf5 -y copr disable scottames/ghostty
dnf5 -y copr disable dejan/lazygit

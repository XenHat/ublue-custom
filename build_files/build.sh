#!/bin/bash

set -ouex pipefail

# Enable Copr support
dnf5 install -y dnf5-plugins

# Remove KDE Entirely
dnf5 remove -y plasma* kde* kf5* kf6* gnome-* gtk-*
# not stable yet, this removes too much: flatpak-preinstall.service fails with 'preinstall is not a flatpak command'
# dnf5 remove -y libwayland-client libX11

# Add COPRs
dnf5 -y copr enable errornointernet/quickshell
dnf5 -y copr enable avengemedia/dms
# dnf5 -y copr enable scottames/ghostty
dnf5 -y copr enable dejan/lazygit
# dnf5 -y copr enable chapien/SIF
dnf5 config-manager addrepo --from-repofile=https://download.opensuse.org/repositories/home:/mkittler/Fedora_43/home:mkittler.repo # syncthingtray

# Login Manager
dnf5 install -y greetd dms-greeter
# Add required user for the login manager
useradd --system --no-create-home --shell /bin/false _greetd
mkdir /var/cache/dms-greeter
systemctl disable gdm lightdm sddm
systemctl enable greetd

# Steam Icons Fixer
# dnf5 install -y sif-steam

# Papirus icon theme (recommended for DMS theming)
dnf5 install -y papirus-icon-theme

# Personal packages
dnf5 install -y tmux neovim keepassxc flatpak zsh btop lazygit \
  ImageMagick syncthing shellcheck gamemode \
  syncthingtray libappindicator libappindicator-gtk3 libappindicator-sharp \
  dms matugen niri quickshell xwayland-satellite pcmanfm gvfs-smb \
  fd-find tuned-utils

dnf5 -y autoremove

# Disable COPRs so they don't end up enabled on the final image:
dnf5 -y copr disable errornointernet/quickshell
dnf5 -y copr disable avengemedia/dms
# dnf5 -y copr disable scottames/ghostty
dnf5 -y copr disable dejan/lazygit
# dnf5 -y copr disable chapien/SIF

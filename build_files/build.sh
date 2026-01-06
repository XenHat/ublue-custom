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
dnf5 -y copr enable scottames/ghostty
dnf5 -y copr enable dejan/lazygit
dnf5 -y copr enable chapien/SIF
dnf5 config-manager addrepo --from-repofile=https://download.opensuse.org/repositories/home:/mkittler/Fedora_43/home:mkittler.repo # syncthingtray

# Login Manager
dnf5 install -y greetd dms-greeter
# Add required user for the login manager
useradd --system --no-create-home --shell /bin/false _greetd
mkdir /var/cache/dms-greeter
systemctl disable gdm lightdm sddm
systemctl enable greetd

# Steam Icons Fixer
dnf5 install -y sif-steam

# Papirus icon theme (recommended for DMS theming)
dnf5 install -y papirus-icon-theme

# Personal packages
dnf5 install -y tmux neovim keepassxc flatpak zsh btop ghostty lazygit \
  ImageMagick syncthing shellcheck gamemode \
  syncthingtray libappindicator libappindicator-gtk3 libappindicator-sharp \
  dms matugen niri quickshell xwayland-satellite \
  fd-find

dnf5 -y autoremove

# Disable COPRs so they don't end up enabled on the final image:
dnf5 -y copr disable errornointernet/quickshell
dnf5 -y copr disable avengemedia/dms
dnf5 -y copr disable scottames/ghostty
dnf5 -y copr disable dejan/lazygit

# Development packages to build dkms packages such as LenovoLegionLinux
sudo dnf5 install -y kernel-headers kernel-devel dmidecode lm_sensors python3-PyQt6 python3-yaml python3-pip python3-argcomplete
# This does not work at the moment
# pip install darkdetect --root-user-action ignore
sudo dnf5 -y group install "development-tools"
sudo dnf5 -y group install "c-development"
# Install the following for installation with DKMS
sudo dnf5 -y install dkms openssl mokutil
git clone https://github.com/johnfanv2/LenovoLegionLinux && cd LenovoLegionLinux && cd kernel_module && make && sudo make install

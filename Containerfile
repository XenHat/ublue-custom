# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /

# Base Image
FROM ghcr.io/ublue-os/aurora-nvidia-open@sha256:a21aab0abf7af14ec217e0cc54fe8de28c93e7c5c20e73bba09782e2a1e080af
# FROM quay.io/fedora/fedora-coreos:stable

## Other possible base images include:
# FROM ghcr.io/ublue-os/bazzite:latest
# FROM ghcr.io/ublue-os/bluefin-nvidia:stable
# 
# ... and so on, here are more base images
# Universal Blue Images: https://github.com/orgs/ublue-os/packages
# Fedora base image: quay.io/fedora/fedora-bootc:41
# CentOS base images: quay.io/centos-bootc/centos-bootc:stream10

### [IM]MUTABLE /opt
## Some bootable images, like Fedora, have /opt symlinked to /var/opt, in order to
## make it mutable/writable for users. However, some packages write files to this directory,
## thus its contents might be wiped out when bootc deploys an image, making it troublesome for
## some packages. Eg, google-chrome, docker-desktop.
##
## Uncomment the following line if one desires to make /opt immutable and be able to be used
## by the package manager.

# RUN rm /opt && mkdir /opt

### MODIFICATIONS
## make modifications desired in your image and install packages by modifying the build.sh script
## the following RUN directive does all the things required to run "build.sh" as recommended.


# Enable Copr support
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
  --mount=type=cache,dst=/var/cache \
  --mount=type=cache,dst=/var/log \
  --mount=type=tmpfs,dst=/tmp \
  dnf5 install -y dnf5-plugins

# Add more repositories
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
  --mount=type=cache,dst=/var/cache \
  --mount=type=cache,dst=/var/log \
  --mount=type=tmpfs,dst=/tmp \
  dnf5 -y copr enable errornointernet/quickshell && \
  dnf5 -y copr enable avengemedia/dms && \
  dnf5 -y copr enable scottames/ghostty && \
  dnf5 -y copr enable dejan/lazygit && \
  dnf5 config-manager addrepo --from-repofile=https://download.opensuse.org/repositories/home:/mkittler/Fedora_43/home:mkittler.repo

# Remove KDE Entirely
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
  --mount=type=cache,dst=/var/cache \
  --mount=type=cache,dst=/var/log \
  --mount=type=tmpfs,dst=/tmp \
  dnf5 remove -y plasma* kde* kf5* kf6* && \
  dnf5 autoremove -y

# Login Manager
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
  --mount=type=cache,dst=/var/cache \
  --mount=type=cache,dst=/var/log \
  --mount=type=tmpfs,dst=/tmp \
  dnf5 install -y greetd dms-greeter

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
  dnf5 install -y linux-firmware && \
  dnf5 install -y kmod-nvidia ublue-os-nvidia-addons nvidia-driver nvidia-settings nvidia-gpu-firmware

# Copy configuration files
COPY etc /etc
# Add required user for the login manager
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
  --mount=type=cache,dst=/var/cache \
  --mount=type=cache,dst=/var/log \
  --mount=type=tmpfs,dst=/tmp \
  useradd --system --no-create-home --shell /bin/false _greetd && \
  mkdir /var/cache/dms-greeter && \
  systemctl disable gdm lightdm sddm && \
  systemctl enable greetd

# Personal packages

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    dnf5 install -y tmux neovim keepassxc flatpak zsh btop ghostty lazygit \
      ImageMagick syncthing shellcheck gamemode \
      clang lld bolt mold llvm-cmake-utils polly \
      syncthing syncthingtray \
      dms matugen niri quickshell xwayland-satellite

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint

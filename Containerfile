# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /

# Base Image
# FROM ghcr.io/ublue-os/aurora-nvidia-open@sha256:a21aab0abf7af14ec217e0cc54fe8de28c93e7c5c20e73bba09782e2a1e080af
FROM ghcr.io/xenhat/base-nogui:latest
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


# Login Manager
RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
  --mount=type=cache,dst=/var/cache \
  --mount=type=cache,dst=/var/log \
  --mount=type=tmpfs,dst=/tmp \
  dnf5 -y copr enable avengemedia/dms && \
  dnf5 install -y greetd dms-greeter && \
  dnf5 -y copr disable avengemedia/dms

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
    dnf5 -y copr enable dejan/lazygit &&
    dnf5 install -y tmux neovim keepassxc flatpak zsh btop ghostty lazygit \
      ImageMagick syncthing shellcheck gamemode \
      clang lld bolt mold llvm-cmake-utils polly \
      syncthing syncthingtray \
      dms matugen niri quickshell xwayland-satellite &&
      dnf -y copr disable dejan/lazygit

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint

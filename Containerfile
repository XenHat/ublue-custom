# Allow build scripts to be referenced without being copied into the final image
FROM scratch AS ctx
COPY build_files /

# Base Image
FROM ghcr.io/ublue-os/aurora-nvidia-open@sha256:a21aab0abf7af14ec217e0cc54fe8de28c93e7c5c20e73bba09782e2a1e080af
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

RUN --mount=type=bind,from=ctx,source=/,target=/ctx \
    --mount=type=cache,dst=/var/cache \
    --mount=type=cache,dst=/var/log \
    --mount=type=tmpfs,dst=/tmp \
    /ctx/build.sh

### LINTING
## Verify final image and contents are correct.
RUN bootc container lint

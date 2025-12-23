#!/bin/bash

set -ouex pipefail

# Disable COPRs so they don't end up enabled on the final image:
dnf5 -y copr disable errornointernet/quickshell
dnf5 -y copr disable avengemedia/dms
dnf5 -y copr disable scottames/ghostty
dnf5 -y copr disable dejan/lazygit

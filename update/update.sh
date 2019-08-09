#!/usr/bin/env bash
set -euo pipefail

cd /bundle_update

echo "Running pre install script or command..."
eval "$PRE_BUNDLE_UPDATE"

bundle update --jobs="$(nproc)"

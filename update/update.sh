#!/usr/bin/env bash
set -euo pipefail

cd /bundle_update

echo "Running pre install script..."
eval "$PRE_BUNDLE_UPDATE"

bundle update --jobs="$(nproc)"

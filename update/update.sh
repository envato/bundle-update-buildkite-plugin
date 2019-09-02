#!/usr/bin/env bash
set -euo pipefail

cd /bundle_update

echo "Running pre bundle update"
eval "$PRE_BUNDLE_UPDATE"

bundle update --jobs="$(nproc)"

echo "Running post bundle update"
eval "$POST_BUNDLE_UPDATE"

#!/usr/bin/env bash
set -euo pipefail

cd /bundle_update

echo "--- :shell: Running pre bundle update"
eval "$PRE_BUNDLE_UPDATE"

echo "+++ :bundler: Running bundle update"
bundle update --jobs="$(nproc)"

echo "--- :shell: Running post bundle update"
eval "$POST_BUNDLE_UPDATE"

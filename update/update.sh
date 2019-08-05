#!/usr/bin/env bash
set -euo pipefail

cd /bundle_update

if [ -f ".buildkite/scripts/pre-bundle-update" ]; then
    echo "Installing custom dependencies..."
    eval ".buildkite/scripts/pre-bundle-update"
fi

bundle update --jobs="$(nproc)"

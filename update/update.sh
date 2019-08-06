#!/usr/bin/env bash
set -euo pipefail

cd /bundle_update

if [ -f $BUILDKITE_PLUGIN_BUNDLE_UPDATE_PRE_BUNDLE_UPDATE ]; then
    echo "Running pre install script..."
    eval $BUILDKITE_PLUGIN_BUNDLE_UPDATE_PRE_BUNDLE_UPDATE
fi

bundle update --jobs="$(nproc)"

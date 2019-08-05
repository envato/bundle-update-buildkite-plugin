#!/usr/bin/env bash
set -euo pipefail

cd /bundle_update

echo "pre_bundle_update=$PRE_BUNDLE_UPDATE"

echo "BUILDKITE_PLUGIN_BUNDLE_UPDATE_PRE_BUNDLE_UPDATE=$BUILDKITE_PLUGIN_BUNDLE_UPDATE_PRE_BUNDLE_UPDATE"

if [ -f "$pre_bundle_update" ]; then
    echo "$pre_bundle_update exist"
else
    echo "$pre_bundle_update does not exist"
    pre_bundle_update="./buildkite/scripts/pre-bundle-update"
fi

eval ".buildkite/scripts/pre-bundle-update"
# custom defined script
# run it..


bundle update --jobs="$(nproc)"

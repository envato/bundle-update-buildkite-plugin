#!/usr/bin/env bash
set -euo pipefail


function plugin_read_config() {
  local var="BUILDKITE_PLUGIN_BUNDLE_UPDATE_${1}"
  local default="${2:-}"
  echo "${!var:-$default}"
}


cd /bundle_update
pre_bundle_update=$(plugin_read_config PRE_BUNDLE_UPDATE)
echo "pre_bundle_update=${pre_bundle_update}"

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

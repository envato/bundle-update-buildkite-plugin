#!/usr/bin/env bash
set -euo pipefail

PLUGIN_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd)/.."

# shellcheck source=lib/config.sh
. "$PLUGIN_DIR/lib/config.sh"

cd /bundle_update
pre_bundle_update=$(plugin_read_config PRE_BUNDLE_UPDATE)
echo "pre_bundle_update=${pre_bundle_update}"

if [ -f "$pre_bundle_update" ]; then
    echo "$pre_bundle_update exist"
else
    echo "$pre_bundle_update does not exist"
    pre_bundle_update="./buildkite/scripts/pre-bundle-update"
fi

eval pre_bundle_update
# custom defined script
# run it..


bundle update --jobs="$(nproc)"

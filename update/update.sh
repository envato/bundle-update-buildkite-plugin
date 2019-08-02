#!/usr/bin/env bash
set -euo pipefail

cd /bundle_update

# check if hook file exists.
.buildkite/scripts/pre-bundle-update
# custom defined script
# run it..

bundle update --jobs="$(nproc)"

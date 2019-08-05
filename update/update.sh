#!/usr/bin/env bash
set -euo pipefail

cd /bundle_update

. "buildkite/scripts/pre-bundle-update"

bundle update --jobs="$(nproc)"

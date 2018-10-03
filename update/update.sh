#!/usr/bin/env bash
set -euo pipefail

cd /bundle_update
bundle update --jobs="$(nproc)"

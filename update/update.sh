#!/usr/bin/env bash
set -euo pipefail

cd /bundle_update

if [ -f "$PRE_BUNDLE_UPDATE" ]; then
  echo "Running pre install script..."
  eval "$PRE_BUNDLE_UPDATE"
else
  echo "Specified file location does not exist $PRE_BUNDLE_UPDATE"
  exit 1
fi

bundle update --jobs="$(nproc)"

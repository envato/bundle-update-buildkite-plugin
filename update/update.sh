#!/bin/sh
set -eu

cd /bundle_update

if [ -n "$PRE_BUNDLE_UPDATE" ]; then
  echo "--- :shell: Running pre bundle update"
  eval "$PRE_BUNDLE_UPDATE"
fi

echo "+++ :bundler: Running bundle update"
bundle update --jobs="$(nproc)"

if [ -n "$POST_BUNDLE_UPDATE" ]; then
  echo "--- :shell: Running post bundle update"
  eval "$POST_BUNDLE_UPDATE"
fi

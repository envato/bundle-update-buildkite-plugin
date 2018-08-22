#!/usr/bin/env bash
set -euo pipefail

function plugin_read_config() {
  local var="BUILDKITE_PLUGIN_BUNDLE_UPDATE_${1}"
  local default="${2:-}"
  echo "${!var:-$default}"
}

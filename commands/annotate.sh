#!/usr/bin/env bash
set -euo pipefail

repository=$(plugin_read_config REPOSITORY "$(repo_from_origin)")
pull_request=$(plugin_read_config PULL_REQUEST)
if [[ -z "${pull_request}" ]]; then
  pull_request_metadata_key=$(plugin_read_config PULL_REQUEST_METADATA_KEY)
  pull_request=$(buildkite-agent meta-data get "${pull_request_metadata_key}")
fi
image=ruby

echo "--- :docker: Fetching the latest ${image} image"
docker pull "${image}"

echo "--- :docker: Launching ${image} image"
args=(
  "--interactive"
  "--tty"
  "--rm"
  "--volume" "$PLUGIN_DIR/unwrappr:/unwrappr"
  "--workdir" "/annotate"
  "--env" "GITHUB_TOKEN"
)
docker run "${args[@]}" "${image}" /unwrappr/annotate.sh "${repository}" "${pull_request}"

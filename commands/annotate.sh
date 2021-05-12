#!/usr/bin/env bash
set -euo pipefail

repository=$(plugin_read_config REPOSITORY "$(repo_from_origin)")
pull_request=$(plugin_read_config PULL_REQUEST)
if [[ -z "${pull_request}" ]]; then
  pull_request_metadata_key=$(plugin_read_config PULL_REQUEST_METADATA_KEY)
  pull_request=$(buildkite-agent meta-data get "${pull_request_metadata_key}")
fi
image=${BUILDKITE_PLUGIN_BUNDLE_UPDATE_IMAGE:-ruby}

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

# check the list of Gemfiles to annotate, these are newline delimited
gemfile_lock_files=()
while IFS=$'\n' read -r gemfile_lock_file ; do
  [[ -n "${gemfile_lock_file:-}" ]] && gemfile_lock_files+=("--lock-file" "${gemfile_lock_file}")
done <<< "$(printf '%s\n' "$(plugin_read_list GEMFILE_LOCK_FILES)")"

docker run "${args[@]}" "${image}" /unwrappr/annotate.sh \
  "${repository}" \
  "${pull_request}" \
  "${gemfile_lock_files[@]-}"

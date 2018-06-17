#!/bin/bash
set -euo pipefail

repository=$(plugin_read_config REPOSITORY "$(repo_from_origin)")
pull_request=$(plugin_read_config PULL_REQUEST)
if [[ -z "${pull_request}" ]]; then
  pull_request_metadata_key=$(plugin_read_config PULL_REQUEST_METADATA_KEY)
  pull_request=$(buildkite-agent meta-data get "${pull_request_metadata_key}")
fi
image=ruby

echo
echo "--- :docker: Fetching the latest ${image} image"
echo

docker pull "${image}"

echo
echo "--- :docker: Launching ${image} image"
echo

args=(
  "--interactive"
  "--tty"
  "--rm"
  "--volume" "$PLUGIN_DIR/unwrappr:/annotate"
  "--workdir" "/annotate"
  "--env" "GITHUB_TOKEN"
)

# Pass to the Docker container all environment variables that begin with
# 'BUNDLE_'
while IFS='=' read -r name _ ; do
  if [[ $name =~ ^BUNDLE_ ]] ; then
    args+=( "--env" "${name}" )
  fi
done < <(env | sort)

docker run "${args[@]}" "${image}" script/annotate.sh "${repository}" "${pull_request}"

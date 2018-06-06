#!/bin/bash

set -euo pipefail

image=${BUILDKITE_PLUGIN_BUNDLE_UPDATE_IMAGE:-ruby:slim}

echo
echo "--- :docker: Fetching the latest ${image} image"
echo

docker pull "${image}"

echo
echo "+++ :bundler: Running bundle update"
echo

args=(
  "--interactive"
  "--tty"
  "--rm"
  "--volume" "$PWD:/bundle_update"
  "--workdir" "/bundle_update"
)

while IFS='=' read -r name _ ; do
  if [[ $name =~ ^BUNDLE_ ]] ; then
    args+=( "--env" "${name}" )
  fi
done < <(env | sort)

docker run "${args[@]}" "${image}" bundle update "--jobs=$(nproc)"

if git diff-index --quiet HEAD -- Gemfile.lock; then
  echo
  echo "No updates"
else
  buildkite-agent meta-data set bundle-update-plugin-changes true
fi

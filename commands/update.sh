#!/usr/bin/env bash
set -euo pipefail

image=${BUILDKITE_PLUGIN_BUNDLE_UPDATE_IMAGE:-ruby:slim}

echo "--- :docker: Fetching the latest ${image} image"
docker pull "${image}"

echo "+++ :bundler: Running bundle update"
args=(
  "--interactive"
  "--tty"
  "--rm"
  "--volume" "$PWD:/bundle_update"
  "--volume" "$PLUGIN_DIR/update:/update"
  "--workdir" "/bundle_update"
  "--env" "BUNDLE_APP_CONFIG=/bundle_app_config"
)
while IFS='=' read -r name _ ; do
  if [[ $name =~ ^BUNDLE_ ]] ; then
    args+=( "--env" "${name}" )
  fi
done < <(env | sort)
docker run "${args[@]}" "${image}" /update/update.sh

if git diff-index --quiet HEAD -- Gemfile.lock; then
  echo "No updates"
  buildkite-agent annotate ":bundler: No gem updates found." --style info
else
  buildkite-agent meta-data set bundle-update-plugin-changes true
fi

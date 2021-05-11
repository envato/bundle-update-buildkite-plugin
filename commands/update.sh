#!/usr/bin/env bash
set -euo pipefail

image=${BUILDKITE_PLUGIN_BUNDLE_UPDATE_IMAGE:-ruby:slim}
pre_bundle_update=${BUILDKITE_PLUGIN_BUNDLE_UPDATE_PRE_BUNDLE_UPDATE:-""}
post_bundle_update=${BUILDKITE_PLUGIN_BUNDLE_UPDATE_POST_BUNDLE_UPDATE:-""}

echo "~~~ :docker: Fetching the latest ${image} image"
docker pull "${image}"

echo "~~~ :docker: Starting up ${image} container"
args=(
  "--interactive"
  "--tty"
  "--rm"
  "--volume" "$PWD:/bundle_update"
  "--volume" "$PLUGIN_DIR/update:/update"
  "--workdir" "/bundle_update"
  "--env" "BUNDLE_APP_CONFIG=/tmp/bundle_app_config"
  "--env" "PRE_BUNDLE_UPDATE=${pre_bundle_update}"
  "--env" "POST_BUNDLE_UPDATE=${post_bundle_update}"
)
while IFS='=' read -r name _ ; do
  if [[ $name =~ ^BUNDLE_ ]] ; then
    args+=( "--env" "${name}" )
  fi
done < <(env | sort)

# append env vars provided in ENV, these are newline delimited
while IFS=$'\n' read -r env ; do
  [[ -n "${env:-}" ]] && args+=("--env" "${env}")
done <<< "$(printf '%s\n' "$(plugin_read_list ENV)")"

docker run "${args[@]}" "${image}" /update/update.sh

# check the list of Gemfiles for changes, these are newline delimited
gemfile_lock_files=()
while IFS=$'\n' read -r gemfile_lock_file ; do
  [[ -n "${gemfile_lock_file:-}" ]] && gemfile_lock_files+=("${gemfile_lock_file}")
done <<< "$(printf '%s\n' "$(plugin_read_list GEMFILE_LOCK_FILES)")"

if git diff-index --quiet HEAD -- "${gemfile_lock_files[@]-Gemfile.lock}"; then
  buildkite-agent annotate ":bundler: No gem updates found." --style info
else
  buildkite-agent meta-data set bundle-update-plugin-changes true
fi

#!/usr/bin/env bash
set -euo pipefail

echo
echo "--- :bundler: Installing Unwrappr"
echo
bundle install --path .bundle --jobs="$(nproc)"

echo
echo "+++ :github: Annotating Github pull request"
echo
repository=$1
pull_request=$2
echo "Annotating https://github.com/${repository}/pull/${pull_request}"
echo
bundle exec unwrappr annotate-pull-request --repo "${repository}" --pr "${pull_request}"

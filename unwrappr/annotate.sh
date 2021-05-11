#!/usr/bin/env bash
set -euo pipefail

echo "--- :bundler: Installing Unwrappr"
cat <<\GEMS > Gemfile
source 'https://rubygems.org/'
gem 'unwrappr'
GEMS
bundle install --jobs="$(nproc)"

echo "+++ :github: Annotating Github pull request"
repository=$1
pull_request=$2
gemfile_lock_files=("${@:3}")

if [[ ${#gemfile_lock_files[@]} -eq 0 ]]; then
  gemfile_lock_files+=("--lock-file" "Gemfile.lock")
fi

echo "Annotating https://github.com/${repository}/pull/${pull_request}"
echo "Files: " "${gemfile_lock_files[@]}"
echo

bundle exec unwrappr annotate-pull-request \
  --repo "${repository}" \
  --pr "${pull_request}" \
  "${gemfile_lock_files[@]}"

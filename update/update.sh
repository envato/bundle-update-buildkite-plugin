#!/usr/bin/env bash
set -euo pipefail

# Bundle updating may download gems from git
# need to add github.com host key to known_hosts
# or the build will hang at accept prompt
ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts

cd /bundle_update
bundle update --jobs="$(nproc)"

#!/usr/bin/env bash
set -euo pipefail

# Bundle updating may download gems from git
# we need to add github.com host key to known_hosts file
# or the build will hang at the prompt to accept the key
ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts

cd /bundle_update
bundle update --jobs="$(nproc)"

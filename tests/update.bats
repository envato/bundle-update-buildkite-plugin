#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

# Uncomment the following to get more detail on failures of stubs
# export DOCKER_STUB_DEBUG=/dev/tty
# export GIT_STUB_DEBUG=/dev/tty
# export BUILDKITE_AGENT_STUB_DEBUG=/dev/tty

@test "Runs the bundle update via Docker" {
  export BUILDKITE_PLUGIN_BUNDLE_UPDATE_UPDATE=true

  stub docker \
    "pull ruby:slim : echo pulled image" \
    "run --interactive --tty --rm --volume /plugin:/bundle_update --volume /plugin/hooks/../update:/update --workdir /bundle_update --env BUNDLE_APP_CONFIG=/bundle_app_config ruby:slim /update/update.sh : echo bundle updated"
  stub git "diff-index --quiet HEAD -- Gemfile.lock : exit 1"
  stub buildkite-agent "meta-data set bundle-update-plugin-changes true : echo meta-data set"

  run $PWD/hooks/command

  assert_success
  assert_output --partial "pulled image"
  assert_output --partial "bundle updated"
  unstub docker
  unstub git
  unstub buildkite-agent
}

@test "Sets buildkite metadata when changes are found" {
  export BUILDKITE_PLUGIN_BUNDLE_UPDATE_UPDATE=true

  stub docker \
    "pull ruby:slim : echo pulled image" \
    "run --interactive --tty --rm --volume /plugin:/bundle_update --volume /plugin/hooks/../update:/update --workdir /bundle_update --env BUNDLE_APP_CONFIG=/bundle_app_config ruby:slim /update/update.sh : echo bundle updated"
  stub git "diff-index --quiet HEAD -- Gemfile.lock : exit 1"
  stub buildkite-agent "meta-data set bundle-update-plugin-changes true : echo meta-data set"

  run $PWD/hooks/command

  assert_success
  assert_output --partial "meta-data set"
  unstub docker
  unstub git
  unstub buildkite-agent
}

@test "Does not buildkite metadata when no changes are found" {
  export BUILDKITE_PLUGIN_BUNDLE_UPDATE_UPDATE=true

  stub docker \
    "pull ruby:slim : echo pulled image" \
    "run --interactive --tty --rm --volume /plugin:/bundle_update --volume /plugin/hooks/../update:/update --workdir /bundle_update --env BUNDLE_APP_CONFIG=/bundle_app_config ruby:slim /update/update.sh : echo bundle updated"
  stub git "diff-index --quiet HEAD -- Gemfile.lock : exit 0"
  stub buildkite-agent "meta-data set bundle-update-plugin-changes true : echo meta-data set"

  run $PWD/hooks/command

  assert_success
  refute_output --partial "meta-data set"
  unstub docker
  unstub git
}

@test "Supports the image option" {
  export BUILDKITE_PLUGIN_BUNDLE_UPDATE_UPDATE=true
  export BUILDKITE_PLUGIN_BUNDLE_UPDATE_IMAGE=my-image

  stub docker \
    "pull my-image : echo pulled image" \
    "run --interactive --tty --rm --volume /plugin:/bundle_update --volume /plugin/hooks/../update:/update --workdir /bundle_update --env BUNDLE_APP_CONFIG=/bundle_app_config my-image /update/update.sh : echo bundle updated"
  stub git "diff-index --quiet HEAD -- Gemfile.lock : exit 1"
  stub buildkite-agent "meta-data set bundle-update-plugin-changes true : echo meta-data set"

  run $PWD/hooks/command

  assert_success
  assert_output --partial "pulled image"
  assert_output --partial "bundle updated"
  unstub docker
  unstub git
  unstub buildkite-agent
}

@test "Passes BUNDLE* environment variables" {
  export BUILDKITE_PLUGIN_BUNDLE_UPDATE_UPDATE=true
  export BUNDLE_RUBYGEMS__EXAMPLE__COM=secret1
  export BUNDLE_RUBYGEMS__EXAMPLE__NET=secret2
  export NOT_AS_BUNDLE_VAR=secret3

  stub docker \
    "pull ruby:slim : echo pulled image" \
    "run --interactive --tty --rm --volume /plugin:/bundle_update --volume /plugin/hooks/../update:/update --workdir /bundle_update --env BUNDLE_APP_CONFIG=/bundle_app_config --env BUNDLE_RUBYGEMS__EXAMPLE__COM --env BUNDLE_RUBYGEMS__EXAMPLE__NET ruby:slim /update/update.sh : echo bundle updated"
  stub git "diff-index --quiet HEAD -- Gemfile.lock : exit 1"
  stub buildkite-agent "meta-data set bundle-update-plugin-changes true : echo meta-data set"

  run $PWD/hooks/command

  assert_success
  assert_output --partial "pulled image"
  assert_output --partial "bundle updated"
  unstub docker
  unstub git
  unstub buildkite-agent
}

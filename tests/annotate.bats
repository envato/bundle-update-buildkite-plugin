#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

# Uncomment the following to get more detail on failures of stubs
# export DOCKER_STUB_DEBUG=/dev/tty
# export GIT_STUB_DEBUG=/dev/tty
# export BUILDKITE_AGENT_STUB_DEBUG=/dev/tty

@test "Annotate runs unwrappr via Docker" {
  export BUILDKITE_PLUGIN_BUNDLE_UPDATE_ANNOTATE=true
  export BUILDKITE_PLUGIN_BUNDLE_UPDATE_REPOSITORY=envato/ruby-service
  export BUILDKITE_PLUGIN_BUNDLE_UPDATE_PULL_REQUEST=42

  stub docker \
    "pull ruby : echo pulled image" \
    "run --interactive --tty --rm --volume /plugin/hooks/../unwrappr:/unwrappr --workdir /annotate --env GITHUB_TOKEN ruby /unwrappr/annotate.sh envato/ruby-service 42 : echo pull request annotated"
  stub git 'remote get-url origin : echo "git@github.com:owner/project"'

  run $PWD/hooks/command

  assert_success
  assert_output --partial "pulled image"
  assert_output --partial "pull request annotated"
  unstub docker
  unstub git
}

@test "Annotate uses the current repository if not provided" {
  export BUILDKITE_PLUGIN_BUNDLE_UPDATE_ANNOTATE=true
  export BUILDKITE_PLUGIN_BUNDLE_UPDATE_PULL_REQUEST=42

  stub docker \
    "pull ruby : echo pulled image" \
    "run --interactive --tty --rm --volume /plugin/hooks/../unwrappr:/unwrappr --workdir /annotate --env GITHUB_TOKEN ruby /unwrappr/annotate.sh owner/project 42 : echo pull request annotated"
  stub git 'remote get-url origin : echo "git@github.com:owner/project"'

  run $PWD/hooks/command

  assert_success
  assert_output --partial "pulled image"
  assert_output --partial "pull request annotated"
  unstub docker
  unstub git
}

@test "Annotate passes BUNDLE_* environment variables to Docker container" {
  export BUNDLE_RUBYGEMS__EXAMPLE__COM=secret1
  export BUNDLE_RUBYGEMS__EXAMPLE__NET=secret2
  export NOT_AS_BUNDLE_VAR=secret3

  export BUILDKITE_PLUGIN_BUNDLE_UPDATE_ANNOTATE=true
  export BUILDKITE_PLUGIN_BUNDLE_UPDATE_REPOSITORY=envato/ruby-service
  export BUILDKITE_PLUGIN_BUNDLE_UPDATE_PULL_REQUEST=42

  stub docker \
    "pull ruby : echo pulled image" \
    "run --interactive --tty --rm --volume /plugin/hooks/../unwrappr:/unwrappr --workdir /annotate --env GITHUB_TOKEN --env BUNDLE_RUBYGEMS__EXAMPLE__COM --env BUNDLE_RUBYGEMS__EXAMPLE__NET ruby /unwrappr/annotate.sh envato/ruby-service 42 : echo pull request annotated"
  stub git 'remote get-url origin : echo "git@github.com:owner/project"'

  run $PWD/hooks/command

  assert_success
  assert_output --partial "pulled image"
  assert_output --partial "pull request annotated"
  unstub docker
  unstub git
}

@test "Annotate obtains the pull request number from build metadata" {
  export BUILDKITE_PLUGIN_BUNDLE_UPDATE_ANNOTATE=true
  export BUILDKITE_PLUGIN_BUNDLE_UPDATE_REPOSITORY=envato/ruby-service
  export BUILDKITE_PLUGIN_BUNDLE_UPDATE_PULL_REQUEST_METADATA_KEY=pull-request

  stub docker \
    "pull ruby : echo pulled image" \
    "run --interactive --tty --rm --volume /plugin/hooks/../unwrappr:/unwrappr --workdir /annotate --env GITHUB_TOKEN ruby /unwrappr/annotate.sh envato/ruby-service 232 : echo pull request annotated"
  stub git 'remote get-url origin : echo "git@github.com:owner/project"'
  stub buildkite-agent "meta-data get pull-request : echo 232"

  run $PWD/hooks/command

  assert_success
  assert_output --partial "pulled image"
  assert_output --partial "pull request annotated"
  unstub docker
  unstub git
  unstub buildkite-agent
}

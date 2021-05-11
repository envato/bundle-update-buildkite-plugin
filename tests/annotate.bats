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

@test "Supports the image option" {
  export BUILDKITE_PLUGIN_BUNDLE_UPDATE_ANNOTATE=true
  export BUILDKITE_PLUGIN_BUNDLE_UPDATE_REPOSITORY=envato/ruby-service
  export BUILDKITE_PLUGIN_BUNDLE_UPDATE_PULL_REQUEST=42
  export BUILDKITE_PLUGIN_BUNDLE_UPDATE_IMAGE=my-image

  stub docker \
    "pull my-image : echo pulled my-image" \
    "run --interactive --tty --rm --volume /plugin/hooks/../unwrappr:/unwrappr --workdir /annotate --env GITHUB_TOKEN my-image /unwrappr/annotate.sh envato/ruby-service 42 : echo pull request annotated"
  stub git 'remote get-url origin : echo "git@github.com:owner/project"'

  run $PWD/hooks/command

  assert_success
  assert_output --partial "pulled my-image"
  assert_output --partial "pull request annotated"
  unstub docker
  unstub git
}

@test "Supports the gemfile-lock-files option" {
  export BUILDKITE_PLUGIN_BUNDLE_UPDATE_ANNOTATE=true
  export BUILDKITE_PLUGIN_BUNDLE_UPDATE_REPOSITORY=envato/ruby-service
  export BUILDKITE_PLUGIN_BUNDLE_UPDATE_PULL_REQUEST=42
  export BUILDKITE_PLUGIN_BUNDLE_UPDATE_GEMFILE_LOCK_FILES=Gemfile_v2.lock

  stub docker \
    "pull ruby : echo pulled image" \
    "run --interactive --tty --rm --volume /plugin/hooks/../unwrappr:/unwrappr --workdir /annotate --env GITHUB_TOKEN ruby /unwrappr/annotate.sh envato/ruby-service 42 --lock-file Gemfile_v2.lock : echo pull request annotated"
  stub git 'remote get-url origin : echo "git@github.com:owner/project"'

  run $PWD/hooks/command

  assert_success
  assert_output --partial "pulled image"
  assert_output --partial "pull request annotated"
  unstub docker
  unstub git
}

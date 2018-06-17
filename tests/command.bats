#!/usr/bin/env bats

load '/usr/local/lib/bats/load.bash'

# Uncomment the following to get more detail on failures of stubs
# export NPROC_STUB_DEBUG=/dev/tty
# export DOCKER_STUB_DEBUG=/dev/tty
# export GIT_STUB_DEBUG=/dev/tty
# export BUILDKITE_AGENT_STUB_DEBUG=/dev/tty

@test "Errors out when update parameter not provided" {
  stub nproc
  stub docker
  stub git
  stub buildkite-agent

  run $PWD/hooks/command

  assert_failure
  assert_output --partial "No update or annotate options were specified"
}

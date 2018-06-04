# Bundle Update Buildkite Plugin

![Build status](https://badge.buildkite.com/3e169bf223b02ed62d3a3090e2ef78cb025e83076c33b694b5.svg?branch=master)
[![MIT License](https://img.shields.io/badge/License-MIT-brightgreen.svg)](LICENSE)

A [Buildkite plugin](https://buildkite.com/docs/agent/v3/plugins) that lets you
run `bundle update` on Ruby projects. If bundle update produces changes the
`bundle-update-plugin-changes: true` key-value pair is added to the build
metadata. This is helpful for triggering later build steps. See the [git
commit](https://github.com/thedyrt/git-commit-buildkite-plugin) and [github
pull request](https://github.com/envato/github-pull-request-buildkite-plugin)
Buildkite plugins for inspiration.

## Example

With no options, downloads the latest `ruby:slim` Docker image, starts it up and runs `bundle update`:

```yml
steps:
  - label: ":bundler: Update"
    plugins:
      envato/bundle-update: ~
```

By specifying a Docker image, you can control which image and hence which version of Ruby and Bundler will be used:

```yml
steps:
  - label: ":bundler: Update"
    plugins:
      envato/bundle-update:
        image: "ruby:2.3.7-slim"
```

## Configuration

### `image` (optional)

The Docker image to use. Checkout the [official Ruby
builds](https://hub.docker.com/_/ruby/) at Docker Hub or build your own.

Default: `ruby:slim`

## Development

To run the tests:

```sh
docker-compose run --rm tests
```

To run the [Buildkite Plugin Linter](https://github.com/buildkite-plugins/buildkite-plugin-linter):

```sh
docker-compose run --rm lint
```

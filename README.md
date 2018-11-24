# Bundle Update Buildkite Plugin

![Build status](https://badge.buildkite.com/3e169bf223b02ed62d3a3090e2ef78cb025e83076c33b694b5.svg?branch=master)
[![MIT License](https://img.shields.io/badge/License-MIT-brightgreen.svg)](LICENSE)

A [Buildkite plugin](https://buildkite.com/docs/agent/v3/plugins) that updates
gem dependencies in your Ruby projects by running `bundle update`.

## Update

This function runs `bundle update` from within a Docker container.

```yml
steps:
  - label: ":bundler: Update"
    plugins:
      - envato/bundle-update#v0.4.0:
          update: true
```

By itself this function is quite useless, the resulting changes to the
`Gemfile.lock` will simply sit in the Buildkite working directory. What we
really want is for the changes to be committed back to the repository. For this
we can make use of the [Git Commit](https://github.com/thedyrt/git-commit-buildkite-plugin)
Buildkite plugin.

```yml
steps:
  - label: ":bundler: Update"
    plugins:
      - envato/bundle-update#v0.4.0:
          update: true
      - thedyrt/git-commit#v0.3.0:
          branch: "bundle-update/${BUILDKITE_BUILD_NUMBER}"
          message: "Bundle update - ${BUILDKITE_BUILD_URL}"
          create-branch: true
          user:
            name: "Bundle Update Bot"
            email: "bundle-update-bot@example.com"
```

One could then use the [Github Pull Request](https://github.com/envato/github-pull-request-buildkite-plugin)
Buildkite plugin to a create pull request with these changes (if your project
codebase is hosted on Github):

```yml
  - label: ":github: Open Pull Request"
    plugins:
      - envato/github-pull-request#v0.4.0:
          head: "bundle-update/${BUILDKITE_BUILD_NUMBER}"
          title: "Bundle update"
          body: "[Bundle update #${BUILDKITE_BUILD_NUMBER}](${BUILDKITE_BUILD_URL})"
```

By defalt the bundle update plugin will use the `ruby:slim` Docker image. But
one can specify a Docker image, this way you can control which version of Ruby
and Bundler will be used. If your project's gems require specific compile-time
packages installed you'll need to choose an image that satisfies these
constraints also.

```yml
steps:
  - label: ":bundler: Update"
    plugins:
      - envato/bundle-update#v0.4.0:
          update: true
          image: "ruby:2.3.7-slim"
```

Bundler can be further configured by setting environment variables it
understands. For instance, if you need to authenticate to access a private
RubyGems server at https://rubygems.example.com, you can set your credentials in
an environment variable named `BUNDLE_RUBYGEMS__EXAMPLE__COM`. (Please use a
secure mechanisim for setting private environment variables. For instance, the
[AWS S3 Secrets Buildkite Plugin](https://github.com/buildkite/elastic-ci-stack-s3-secrets-hooks#environment-variables).)

If bundle update produces changes to `Gemfile.lock` files, the
`bundle-update-plugin-changes: true` key-value pair is added to the build
metadata. This is helpful for triggering or cancelling later steps in the
pipeline.

## Configuration

### `update`

Instruct the plugin to run `bundle update` on the project.

### `image` (optional, update only)

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

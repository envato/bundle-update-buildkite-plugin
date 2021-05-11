# Bundle Update Buildkite Plugin

![Build status](https://badge.buildkite.com/3e169bf223b02ed62d3a3090e2ef78cb025e83076c33b694b5.svg?branch=main)
[![MIT License](https://img.shields.io/badge/License-MIT-brightgreen.svg)](LICENSE)

A [Buildkite plugin](https://buildkite.com/docs/agent/v3/plugins) that updates
gem dependencies in your Ruby projects by running `bundle update`.

## Update

This function runs `bundle update` from within a Docker container.

```yml
steps:
  - label: ":bundler: Update"
    plugins:
      - envato/bundle-update#v0.9.1:
          update: true
```

By itself this function is quite useless, the resulting changes to the
`Gemfile.lock` will simply sit in the Buildkite working directory. What we
really want is for the changes to be committed back to the repository. For this
we can make use of the [Git Commit Buildkite Plugin].

```yml
steps:
  - label: ":bundler: Update"
    plugins:
      - envato/bundle-update#v0.9.1:
          update: true
      - thedyrt/git-commit#v0.3.0:
          branch: "bundle-update/${BUILDKITE_BUILD_NUMBER}"
          message: "Bundle update - ${BUILDKITE_BUILD_URL}"
          create-branch: true
          user:
            name: "Bundle Update Bot"
            email: "bundle-update-bot@example.com"
```

One could then use the [Github Pull Request Buildkite Plugin] to a create pull
request with these changes (if your project codebase is hosted on Github):

```yml
  - label: ":github: Open Pull Request"
    plugins:
      - envato/github-pull-request#v0.4.0:
          head: "bundle-update/${BUILDKITE_BUILD_NUMBER}"
          title: "Bundle update"
          body: "[Bundle update #${BUILDKITE_BUILD_NUMBER}](${BUILDKITE_BUILD_URL})"
```

By default the bundle update plugin will use the `ruby:slim` Docker image. But
one can specify a Docker image, this way you can control which version of Ruby
and Bundler will be used. If your project's gems require specific compile-time
packages installed you'll need to choose an image that satisfies these
constraints also.

```yml
steps:
  - label: ":bundler: Update"
    plugins:
      - envato/bundle-update#v0.9.1:
          update: true
          image: "ruby:2.3.7-slim"
```

If the main build produces a Docker image artifact, it may be easiest to use that
to run the bundle update, as it'll have all the compile-time dependencies
installed. Here's an example obtaining the image from Amazon ECR:

```yml
steps:
  - label: ":bundler: Update"
    plugins:
      - ecr#v1.1.4:
          login: true
          account_ids: 100000000000
      - envato/bundle-update#v0.9.1:
          update: true
          image: "100000000000.dkr.ecr.us-east-1.amazonaws.com/my-service:latest"
```

Bundler can be further configured by setting environment variables it
understands. For instance, if you need to authenticate to access a private
RubyGems server at https://rubygems.example.com, you can set your credentials in
an environment variable named `BUNDLE_RUBYGEMS__EXAMPLE__COM`. (Please use a
secure mechanism for setting private environment variables. For instance, the
[AWS S3 Secrets Buildkite Plugin].)

If bundle update produces changes to `Gemfile.lock` files, the
`bundle-update-plugin-changes: true` key-value pair is added to the build
metadata. This is helpful for triggering or cancelling later steps in the
pipeline.

## Annotate

Add comments to each gem change to a `Gemfile.lock` file in a Github pull
request. These comments provide some context and are helpful to engineers when
determining if the change in version is safe.

This feature is implemented using the [unwrappr] library.

```yml
steps:
  - label: ":rubygems: Annotate Gem Changes"
    plugins:
      - envato/bundle-update#v0.9.1:
          annotate: true
          pull-request: 42
```

By default the plugin uses the repository from the Buildkite pipeline
configuration. However, this can be overridden by specifying the Github
repository:

```yml
steps:
  - label: ":rubygems: Annotate Gem Changes"
    plugins:
      - envato/bundle-update#v0.9.1:
          annotate: true
          pull-request: 42
          repository: "owner/project"
```

The pull request number can also be loaded from the build metadata. For instance,
the [Github Pull Request Buildkite Plugin] saves the PR number with the key
`github-pull-request-plugin-number` so it can be loaded like so:

```yml
steps:
  - label: ":rubygems: Annotate Gem Changes"
    plugins:
      - envato/bundle-update#v0.9.1:
          annotate: true
          pull-request-metadata-key: "github-pull-request-plugin-number"
```

## Installing Custom Dependencies

When running a bundle update from within a docker container, there may or may not
be the dependencies you require for the update to complete successfully.
For example, compiling native extensions or access to a library from another package.

In this case you have 2 options to help solve the problem.

1. Use a docker container which you have prebuilt (or sourced) with all the
   required dependencies.

2. You can specify a script location or shell command which will be executed prior to running the
   bundle update. Here you can install and configure the container as needed.

```yml
steps:
  - label: ":bundler: Update"
    plugins:
      - envato/bundle-update#v0.9.1:
          update: true
          pre-bundle-update: .buildkite/scripts/pre-bundle-update
```

or a command

```yml
steps:
  - label: ":bundler: Update"
    plugins:
      - envato/bundle-update#v0.9.1:
          update: true
          pre-bundle-update: "apk add --no-progress build-base"
```

## Example Pipeline

This is an example pipeline which ties everything together to produce nicely
annotated bundle update pull requests.

This pipeline requires two secrets:

* Write access to the project GIT repository, by way of an [SSH Key][Github
  Deploy Key]. This write access is used for pushing up the bundle update
  commit.

* Github API access, by populating the environment variable `GITHUB_TOKEN` with
  a personal access token providing `repo` access to the repository. This is
  used for opening the pull request and adding comments.

It's recommended to use the [AWS S3 Secrets Buildkite Plugin] to provide these
secrets. With this you can simply upload the `private_ssh_key` file and
`environment` file (containing `GITHUB_TOKEN=<secret-value>`) to your S3
secrets bucket.

```yml
steps:

  - label: ":bundler: Update"
    plugins:
      - envato/bundle-update#v0.9.1:
          update: true
          image: "ruby:2.5"
      - thedyrt/git-commit#v0.3.0:
          branch: "bundle-update/${BUILDKITE_BUILD_NUMBER}"
          message: |
            Bundle update

            ${BUILDKITE_BUILD_URL}
          create-branch: true
          user:
            name: "Bundle Update Bot"
            email: "bundle-update-bot@example.com"
      - envato/stop-the-line#v0.1.0:
          unless:
            key: "bundle-update-plugin-changes"
            value: "true"
          style: "pass"

  - wait

  - label: ":github: Open Pull Request"
    plugins:
      - envato/github-pull-request#v0.4.0:
          head: "bundle-update/${BUILDKITE_BUILD_NUMBER}"
          title: "Bundle update"
          body: |
            Let's upgrade these dependencies for the long-term health and security of the system.

            A slight inconvenience now prevents a severe pain later.

            ([Bundle update #${BUILDKITE_BUILD_NUMBER}](${BUILDKITE_BUILD_URL}))
          labels: hygiene
          team-reviewers: a-team

  - wait

  - label: ":writing_hand: Annotate Changes"
    plugins:
      - envato/bundle-update#v0.9.1:
          annotate: true
          pull-request-metadata-key: github-pull-request-plugin-number
```

1. Save this file to `.buildkite/pipeline.bundle-update.yml` and configure a
   dedicated Buildkite pipeline to load its steps from this location.

2. Configure the private SSH key and Github token as outlined above.

3. Edit the `.buildkite/pipeline.bundle-update.yml` file to use a Docker image
   supports your bundle of gems (and tweak the Git commit and pull request
   message contents to your liking).

4. Then use the Buildkite schedule feature to run the pipeline as often as your
   team desires.

## Configuration

### `update`

Instruct the plugin to run `bundle update` on the project.

### `image` (optional)

The Docker image to use. Checkout the [official Ruby
builds](https://hub.docker.com/_/ruby/) at Docker Hub or build your own.

Default: `ruby:slim`

### `env` (optional, update only)

The environment variables that get passed to the docker container.

```yml
steps:
  - name: ":bundler: Update"
    plugins:
      - envato/bundle-update#v0.9.1:
          update: true
          env:
            - BUILDKITE_BUILD_NUMBER
            - MY_CUSTOM_ENV=llamas
```

Note how the values in the list can either be just a key (so the value is sourced from the environment) or a KEY=VALUE pair.

### `gemfile-lock-files` (optional, update only)

The Gemfile lock files to check for changes post `bundle update`.

Default: `Gemfile.lock`

### `post-bundle-update` (optional, update only)

A script or command to run inside the docker container after the bundle update.

### `pre-bundle-update` (optional, update only)

The script or command to run inside the docker container prior to the bundle update.
Used to install any dependencies that the bundle update needs if not already in
the container.

### `annotate`

Instruct the plugin to run annotate `Gemfile.lock` gem changes in a Github pull
request.

### `pull-request` (optional, annotate only)

The number of the Github pull request to annotate. This or
`pull-request-metadata-key` needs to be provided for the `annotate` function.

### `pull-request-metadata-key` (optional, annotate only)

The Buildkite metadata key to the Github pull request number. This or
`pull-request` needs to be provided for the `annotate` function.

### `repository` (optional, annotate only)

The Github repository.

Default: pipeline configured repository

## Development

To run the tests:

```sh
docker-compose run --rm tests
```

To run the [Buildkite Plugin Linter](https://github.com/buildkite-plugins/buildkite-plugin-linter):

```sh
docker-compose run --rm lint
```

[unwrappr]: https://github.com/envato/unwrappr
[Github Deploy Key]: https://developer.github.com/v3/guides/managing-deploy-keys/#deploy-keys
[Git Commit Buildkite Plugin]: https://github.com/thedyrt/git-commit-buildkite-plugin
[Github Pull Request Buildkite Plugin]: https://github.com/envato/github-pull-request-buildkite-plugin
[AWS S3 Secrets Buildkite Plugin]: https://github.com/buildkite/elastic-ci-stack-s3-secrets-hooks#uploading-secrets

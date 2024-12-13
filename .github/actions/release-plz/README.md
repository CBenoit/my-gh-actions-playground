# `release-plz` action

Action for [release-plz](https://github.com/release-plz/release-plz).

This action requires an Ubuntu runner.

## Usage

```yaml
- uses: Devolutions/actions/release-plz@v1
  with:
    # The release-plz command to run
    #
    # Possible values: release-pr, release
    #
    # Required
    command: ''

    # Config file location
    #
    # If not present, the default 'release-plz.toml' is used
    config: ''

    # Path to the Cargo.toml of the project to update
    manifest-path: ''

    # release-plz version to use
    #
    # Default: '0.3.111'
    release-plz-version: ''

    # cargo-semver-checks version to use
    #
    # Default: '0.38.0'
    cargo-semver-checks-version: ''

    # Registry token (crates.io, ...)
    #
    # Required
    registry-token: ''

    # GitHub token
    #
    # Default: ${{ github.token }}
    github-token: ''

    # Git author name
    #
    # Default: 'github-actions'
    git-name: ''

    # Git author email
    #
    # Default: 'github-actions@github.com'
    git-email: ''
```

## Scenarios

### Create a PR with the new versions and changelog files, preparing the next release

```yaml
- uses: Devolutions/actions/release-plz@v1
  with:
    command: release-pr
```

### Release unpublished packages

```yaml
- uses: Devolutions/actions/release-plz@v1
  with:
    command: release
    registry-token: ${{ secrets.CRATES_IO_DEVOLUTIONSBOT_API_KEY }}
```

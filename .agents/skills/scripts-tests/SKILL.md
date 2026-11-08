---
name: scripts-tests
description: How to run and verify the Scripts test suites (shellcheck, bats, rubocop, Ruby/AppleScript syntax) on macOS and in CI, the accepted baseline, and what the tests do not cover. Load before running tests or reporting test results.
license: MIT
compatibility: opencode
---

# Tests and verification

## Run the checks

Run from the repository root:

```sh
find src -name '*.sh' -print0 | xargs -0 shellcheck
bats test
rubocop
git diff --check
```

Syntax-check changed entry points and libraries:

```sh
ruby -c src/github-stats/stats.rb
ruby -c src/gource_combinator/combine.rb
ruby -c src/gmail/import.rb
ruby -c src/music/love_importer.rb
ruby -c src/photos/dater.rb
find src -name '*.rb' -print0 | xargs -0 -n1 ruby -c
osacompile -o /dev/null src/finder/new-finder-window.applescript
```

Only syntax-check the AppleScript files that run on the current macOS; they
have no CI coverage.

## Local prerequisites

- `bats` (Homebrew `bats-core`), `shellcheck`, `rubocop`, and a Ruby on the
  `PATH`.
- The bats suites load helpers from `test/test_helper/`, which CI creates.
  Install them locally (they are gitignored and must not be committed):

  ```sh
  mkdir -p test/test_helper
  git clone --depth 1 --branch v0.3.0 \
    https://github.com/bats-core/bats-support.git \
    test/test_helper/bats-support
  git clone --depth 1 --branch v2.1.0 \
    https://github.com/bats-core/bats-assert.git \
    test/test_helper/bats-assert
  ```

- Some scripts shell out to macOS-only tools (`ffmpeg`, `ffprobe`,
  `gifsicle`, `gource`, `osascript`, `plutil`, Music/Photos/Finder). Missing
  tools do not affect `bats test`, `shellcheck`, or `rubocop`.

## Accepted baseline

- `shellcheck`: 0 findings for every `.sh` file.
- `bats test`: 8/8 tests pass (`test/fader.bats`).
- `rubocop`: 0 offenses.
- `git diff --check`: clean.

CI runs `shellcheck`, `bats`, and `rubocop` on Ubuntu. The RuboCop job runs
on a newer Ruby but `.rubocop.yml` targets Ruby 2.7 syntax. Local Ruby and
RuboCop may differ, so a green local run is not proof of CI compatibility.

## What the tests cover

- `test/fader.bats` exercises argument validation and help output in
  `src/fader/fader.sh` only.
- It does **not** run `ffmpeg`/`ffprobe`, touch the filesystem beyond creating
  `/tmp/foo.mp4`, or test the Ruby, Gmail, Music, Photos, Gource, Finder, or
  Address Book scripts.
- There are no integration tests for the network-facing Ruby scripts. Report
  those changes as unverified unless you ran them manually.

## Verification before reporting done

- Run the checks that match the change; do not claim a suite passed if its
  helper prerequisites were missing.
- Check `git diff --check` before committing.
- Commit messages: GPG-signed, header under 50 characters, body wrapped at 70.

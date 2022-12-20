#!/usr/bin/env bats

setup() {
  load 'test_helper/bats-support/load'
  load 'test_helper/bats-assert/load'
  # ... the remaining setup is unchanged

  # get the containing directory of this file
  # use $BATS_TEST_FILENAME instead of ${BASH_SOURCE[0]} or $0,
  # as those will point to the bats executable's location or the preprocessed file respectively
  DIR="$( cd "$( dirname "$BATS_TEST_FILENAME" )" >/dev/null 2>&1 && pwd )"
  # make executables in src/ visible to PATH
  PATH="$DIR/../src/fader:$PATH"
  touch /tmp/foo.mp4
}

@test "no arguments prints error" {
  run fader.sh
  assert_output --partial "Error! Missing required argument: --file <input-file>"
  assert_output --partial "Usage:"
}

@test "--help prints usage" {
  run fader.sh --help
  assert_output --partial "Usage:"
  assert_output --partial "Fades in and out the video and audio of a file, using ffmpeg."
}

@test "--fade-in or --fade-out are required" {
  run fader.sh --file /tmp/foo.mp4
  assert_output --partial "Error! If neither --fade-in nor --fade-out are specified, there is nothing to do."
  assert_output --partial "Usage:"
}

@test "--fade-in must be numerical" {
  run fader.sh --file /tmp/foo.mp4 --fade-in foo
  assert_output --partial "Error! Fade-in seconds 'foo' not numerical"
  assert_output --partial "Usage:"
}

@test "--fade-out must be numerical" {
  run fader.sh --file /tmp/foo.mp4 --fade-out foo
  assert_output --partial "Error! Fade-out seconds 'foo' not numerical"
  assert_output --partial "Usage:"
}

@test "file must exist" {
  run fader.sh --file /tmp/bar.mp4 --fade-in 1
  assert_output --partial "Error! Input file '/tmp/bar.mp4' does not exist"
  assert_output --partial "Usage:"
}

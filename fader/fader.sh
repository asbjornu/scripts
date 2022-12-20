#!/usr/bin/env bash
#
# Credit to pepa65 for the original script found at:
# https://dev.to/dak425/add-fade-in-and-fade-out-effects-with-ffmpeg-2bj7#comment-10pkh
#
# Copyright 2022 Asbjørn Ulsberg
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of
# this software and associated documentation files (the "Software"), to deal in
# the Software without restriction, including without limitation the rights to
# use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
# the Software, and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
# FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
# COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
# IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#

set -o errexit # Abort if any command fails
me=$(basename "$0")

help_message="\
Fades in and out the video and audio of a file, using ffmpeg.

Usage:
  ${me} --file <input-file> [--fade-in <seconds>] [--fade-out <seconds>] [--verbose]
  ${me} --help
Arguments:
  -f, --file <input-file>       The file to fade in and out. Must be a video
                                file that ffmpeg can read. The output file will
                                be written to the same directory as the input,
                                with the same name and the extension .mp4.
  -i, --fade-in <seconds>       Fade in the video and audio for the specified
                                number of seconds.
  -o, --fade-out <seconds>      Fade out the video and audio for the specified
                                number of seconds.
  -h, --help                    Displays this help screen.
  -v, --verbose                 Increase verbosity. Useful for debugging."

parse_args() {
  while : ; do
      if [[ $1 = "-h" || $1 = "--help" ]]; then
          echo "${help_message}"
          return 0
      elif [[ $1 = "-v" || $1 = "--verbose" ]]; then
          verbose=true
          shift
      elif [[ $1 = "-i" || $1 = "--fade-in" ]]; then
          fade_in=${2// }
          shift 2
      elif [[ $1 = "-o" || $1 = "--fade-out" ]]; then
          fade_out=${2// }
          shift 2
      elif [[ $1 = "-f" || $1 = "--file" ]]; then
          file=${2// }
          shift 2
      else
          break
      fi
  done

  if [[ -z "${file}" ]]; then
      echo "Missing required argument: --file <input-file>" >&2
      echo "${help_message}"
      return 1
  elif [ ! -f "${file}" ]; then
      echo "Input file '${file}' does not exist" >&2
      echo "${help_message}"
      return 1
  elif [ "${verbose}" = true ]; then
    echo "Input file: ${file}"
  fi

  if [[ -z "${fade_in}" && -z "${fade_out}" ]]; then
      echo "If neither --fade-in nor --fade-out are specified, there is nothing to do." >&2
      echo "${help_message}"
      return 1
  fi

  if [[ -z $fade_in || ${fade_in//[0-9]} ]]; then
      echo "Fade-in seconds '${fade_in}' not numerical" >&2
      echo "${help_message}"
      return 1
  fi

  if [[ -z $fade_out || ${fade_out//[0-9]} ]]; then
      echo "Fade-in seconds '${fade_out}' not numerical" >&2
      echo "${help_message}"
      return 1
  fi

  if [ "${verbose}" = true ]; then
    [ -n "${fade_in}" ] && echo "Fade in: ${fade_in}"
    [ -n "${fade_out}" ] && echo "Fade out: ${fade_out}"
  fi

  return 0
}

# Echo expanded commands as they are executed (for debugging)
enable_expanded_output() {
  if [ "${verbose}" = true ]; then
    set -o xtrace
    set +o verbose
  fi
}

probe_length() {
  if [ -z "${file}" ]; then return 1; fi

  # `ffprobe` gives us the length of the video in seconds
  video_length=$(\
    ffprobe \
      -loglevel error \
      -select_streams v:0 \
      -show_entries stream=duration \
      -of default=noprint_wrappers=1:nokey=1 \
      "${file}" \
  )

  [ "${verbose}" = true ] && echo "Video length: ${video_length} seconds."
}

fade_in_out() {
  local video_filter=""
  local audio_filter=""
  local time_start

  if [[ -n "${fade_in}" ]]; then
    video_filter="fade=t=in:st=0:d=${fade_in}"
    audio_filter="afade=t=in:st=0:d=${fade_in}"
  fi

  if [[ -n "${fade_out}" ]]; then
    if [[ -n "${video_filter}" ]]; then
      video_filter="${video_filter},"
      audio_filter="${audio_filter},"
    fi
    # `bc` performs the floating point math required to calculate the start time
    time_start="$(echo "${video_length}" - "${fade_out}" | bc)"

    [ "${verbose}" = true ] && echo "Fade out start time: ${time_start} seconds."

    video_filter="${video_filter}fade=t=out:st=${time_start}:d=${fade_out}"
    audio_filter="${audio_filter}afade=t=out:st=${time_start}:d=${fade_out}"
  fi

  ffmpeg \
    -i "${file}" \
    -filter:v "${video_filter}" \
    -filter:a "${audio_filter}" \
    "${file}.mp4"
}

main() {
    enable_expanded_output
    if parse_args "$@" ; then
      probe_length && fade_in_out
    fi
}

main "$@"

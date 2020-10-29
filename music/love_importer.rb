#!/usr/local/opt/ruby/bin/ruby -w
# frozen_string_literal: false

require_relative 'lib/args'
require_relative 'lib/track_parser'

module LoveImporter
  class << self
    def exec
      Args.parse do |args|
        case args[:command]
        when :import
          import(args[:path])
        end
      end
    end

    private

    def import(path)
      TrackParser.parse(path) do |track|
        puts "Loving '#{track.artist} – #{track.name}'..."

        as = "osascript -e 'tell application \"Music\" to set loved of (first file track of playlist \"Library\" whose artist contains \"%{artist}\" and name contains \"%{name}\") to true'" % {
          # Escape single quote with the following crazy sequence of characters thanks to <https://stackoverflow.com/a/1250279/61818>
          artist: track.artist.gsub("'", "'\"'\"'"),
          name: track.name.gsub("'", "'\"'\"'")
        }

        # puts as

        success = system as

        unless success
          puts "  Error! Unable to love '#{track.artist} - #{track.name}'"
        end
      end
    end
  end
end

LoveImporter.exec

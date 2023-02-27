# frozen_string_literal: true

require 'plist'
require_relative 'track'

# LoveImporter module.
module LoveImporter
  # TrackParser class
  class TrackParser
    def self.parse(path)
      raise ArgumentError, 'path cannot be nil' if path.nil?
      raise ArgumentError, "<#{path}> must be a String" unless path.is_a? String

      path = File.expand_path path

      raise ArgumentError, "<#{path}> not found" unless File.file? path

      puts "Parsing <#{path}>..."

      library = Plist.parse_xml(path)

      library['Tracks'].each do |_id, track|
        next unless track['Loved']

        yield Track.new(track)
      end
    end
  end
end

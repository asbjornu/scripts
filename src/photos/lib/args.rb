# frozen_string_literal: false

require 'docopt'

module Dater
  class Args
    def self.parse
      doc = <<~DOCOPT
        Sets the created and modified date of photos in folders named by the
        year the photos were taken. With more than one photo in each folder,
        the photos will be sorted alphabetically and evenly distributed across
        the months within the range of years. Given the following folder
        structure:

          ~/Pictures/2002-2003/photo1.jpg
          ~/Pictures/2002-2003/photo2.jpg
          ~/Pictures/2002-2003/photo3.jpg
          ~/Pictures/2002-2003/photo4.jpg
          ~/Pictures/2004/photo5.jpg
          ~/Pictures/2004/photo6.jpg
          ~/Pictures/2004/photo7.jpg
          ~/Pictures/2004/photo8.jpg
          ~/Pictures/2004/photo9.jpg

        The photos will be dated as following:

          - photo1.jpg: 2002-01-01
          - photo2.jpg: 2002-06-01
          - photo3.jpg: 2003-01-01
          - photo4.jpg: 2003-06-01
          - photo5.jpg: 2004-01-01
          - photo6.jpg: 2004-03-01
          - photo7.jpg: 2004-06-01
          - photo8.jpg: 2004-09-01
          - photo9.jpg: 2004-12-01

        Usage:
          #{__FILE__} [-h | --help]
          #{__FILE__} <path>

        Arguments:
          <path>              The path to the folder with the photos to date.

        Options:
          -h --help           Print this screen.
      DOCOPT

      args = {}

      begin
        args = Docopt::docopt(doc)
      rescue Docopt::Exit => e
        puts e.message
        exit 1
      end

      path = args["<path>"]
      unless path.is_a?(String)
        puts doc
        exit 1
      end

      path = File.expand_path path

      unless File.directory? path
        puts "Error! The directory <#{path}> does not exist!\n\n"
        puts doc
        exit 1
      end

      path
    end
  end
end

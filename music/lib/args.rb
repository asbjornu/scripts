# frozen_string_literal: false

require 'docopt'

module LoveImporter
  class Args
    def self.parse
      doc = <<~DOCOPT
        Imports the 'loved' status of tracks from an <iTunes Music Library.xml>
        file into the current iTunes or Apple Music library.

        Usage:
          #{__FILE__} [-h | --help]
          #{__FILE__} import <path>

    Commands:
      import              Import the <iTunes Music Library.xml> given in <path>
                          to the current iTunes or Apple Music library.

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
      if args["import"] && path.is_a?(String)
        x = { command: :import, path: path }
        yield x
        return
      end

      puts doc
      exit 1
    end
  end
end

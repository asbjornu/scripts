# frozen_string_literal: true

module LoveImporter
  class Track
    attr_reader :id,
                :size,
                :total_time,
                :number,
                :year,
                :date_modified,
                :date_added,
                :bit_rate,
                :sample_rate,
                :play_count,
                :play_date,
                :play_date_utc,
                :persistent_id,
                :type,
                :file_folder_count,
                :library_folder_count,
                :name,
                :artist,
                :album_artist,
                :album,
                :genre,
                :kind,
                :comments,
                :location

    def initialize(track)
      raise ArgumentError, "track cannot be nil" if track.nil?
      raise ArgumentError, "#{track} must be a Hash" unless track.is_a? Hash

      @id = track["Track ID"] # 9563
      @size = track["Size"] # 9670928
      @total_time = track["Total Time"] # 376920
      @number = track["Track Number"] # 1
      @year = track["Year"] # 2004
      @date_modified = track["Date Modified"] # <DateTime: 2009-07-23T18:43:17+00:00 ((2455036j,67397s,0n),+0s,2299161j)>
      @date_added = track["Date Added"] # <DateTime: 2008-07-26T00:31:55+00:00 ((2454674j,1915s,0n),+0s,2299161j)>"
      @bit_rate = track["Bit Rate"] # 205
      @sample_rate = track["Sample Rate"] # 44100
      @play_count = track["Play Count"] # 4
      @play_date = track["Play Date"] # 3652384670
      @play_date_utc = track["Play Date UTC"] # DateTime: 2019-09-26T21:17:50+00:00 ((2458753j,76670s,0n),+0s,2299161j)>"
      @persistent_id = track["Persistent ID"] # "04B568783055A3AB"
      @type = track["Track Type"] # "File"
      @file_folder_count = track["File Folder Count"] # 4
      @library_folder_count = track["Library Folder Count"] # 1
      @name = track["Name"] # "When the Going Gets Tough, the Tough Get Karazzee"
      @artist = track["Artist"] # "!!!"
      @album_artist = track["Album Artist"] # "!!!"
      @album = track["Album"] # "Louden Up Now"
      @genre = track["Genre"] # "Blues"
      @kind = track["Kind"] # "MPEG audio file"
      @comments = track["Comments"] # " 000008FF 00000893 0000349A 0000544A 0004B4BB 00043DD8 00008000 00008000 00006848 0000C183"
      @location = track["Location"] # "file:///Users/bitbear/Music/iTunes/iTunes%20Music/!!!/Louden%20Up%20Now/01%20When%20the%20Going%20Gets%20Tough,%20the%20Tough%20Get%20Karazzee.mp3",
    end
  end
end

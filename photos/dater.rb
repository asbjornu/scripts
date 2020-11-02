#!/usr/local/opt/ruby/bin/ruby -w

# frozen_string_literal: false

require 'date'
require_relative 'lib/args'

module Dater
  class << self
    def date()
      path = Args.parse

      Dir["#{path}/*"].each do |dir|
        next unless File.directory? dir

        print_and_flush "."

        files = Dir.glob("#{dir}/*").select { |file| File.file? file }.sort
        from, to = period(dir)
        years = to - from + 1
        months = years * 12
        file_per_month = files.length.to_f / months.to_f
        days_between_each_file = 28.to_f / file_per_month

        # puts "#{from} -- #{to} (#{days_between_each_file} / #{months} / #{files.length} / #{file_per_month})"

        year = from
        month = 1
        day = 1
        date = DateTime.new(year, month, day, 12, 00, 00, "+01:00")
        date_s = date.strftime('%Y%m%d%H%M')

        touch = "touch -t #{date_s} '#{dir}'"
        # puts touch
        system touch

        files.each_with_index do |file, index|
          print_and_flush "."

          date = DateTime.new(year, month, day, 12, 00, 00, "+01:00")
          date_s = date.strftime('%Y%m%d%H%M')

          # num = "#{index}."
          # puts "#{num.ljust(4)} #{date_s.ljust(10)}: #{file}"

          day += days_between_each_file

          if day > 28
            day = 1
            month += 1
          end

          if month > 12
            month = 1
            year += 1
          end

          year = year.to_i
          month = month.to_i
          day = day.to_i

          touch = "touch -t #{date_s} '#{file}'"
          # puts touch
          system touch
        end
      end
    end

    private

    def period(dir)
      dir = dir.include?('/') ? dir.split('/').last : dir
      from, to = dir.include?('-') ? dir.split('-') : [dir, dir]

      [from.to_i, to.to_i]
    end

    def print_and_flush(str)
      print str
      $stdout.flush
    end
  end
end

Dater.date

#!/usr/local/opt/ruby@2.7/bin/ruby -w
# frozen_string_literal: true

require_relative 'lib/gource_combinator'

# GitHubStats module.
module GitHubStats
  class << self
    def execute
      if ARGV[0].nil? || ARGV[0].strip.empty?
        print 'GitHub owner: '
        owner = $stdin.gets.chomp
      else
        owner = ARGV[0]
      end

      credentials = {}

      access_token = ENV['GITHUB_TOKEN']
      if access_token.nil? || access_token.strip.empty?
        puts 'GITHUB_TOKEN environment variable is not set. Please enter your credentials.'
        print 'Username: '
        username = $stdin.gets.chomp

        print 'Password: '
        password = $stdin.gets.chomp

        print '2FA code: '
        two_factor_code = $stdin.gets.chomp

        credentials[:username] = username
        credentials[:password] = password
        credentials[:two_factor_code] = two_factor_code unless two_factor_code.nil? || two_factor_code.strip.empty?
      else
        credentials[:access_token] = access_token
      end

      Gource::Combinator.combine(owner, credentials)
    end
  end
end

GitHubStats.execute

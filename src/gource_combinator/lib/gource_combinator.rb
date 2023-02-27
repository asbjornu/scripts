# frozen_string_literal: true

require 'octokit'
require 'fileutils'

# Gource module.
module Gource
  ## Combine and clean logs ready for gource
  ## By Asbjørn Ulsberg
  ## Inspired by https://github.com/acaudwell/Gource/wiki/Visualizing-Multiple-Repositories
  module Combinator
    class << self
      def combine(owner, credentials)
        client = github_client(credentials)
        puts "Fetching repositories for #{owner}."
        repos = client.repositories(owner)
        clone(repos)
      end

      private

      def clone(repos)
        # username mapping fix for incorrect user.name
        username_map = {}

        # get repos or update
        File.delete 'combo.log' if File.exist? 'combo.log'
        FileUtils.mkdir_p 'tmp/repos'
        FileUtils.mkdir_p 'tmp/avatars'

        repos.each do |repo|
          puts "Retrieving #{repo.full_name}."

          repo_dir = "tmp/repos/#{repo.full_name}"
          repo_log = "#{repo.name}.log"

          if Dir.exist? repo_dir
            puts "Updating #{repo.full_name}"
            `git -C tmp/repos/$repo pull`
          else
            puts "Cloning #{repo.full_name}"
            `git clone #{repo.clone_url} #{repo_dir}`
          end

          `gource --output-custom-log #{repo_log} #{$repo_dir}`
          # TODO: Rewrite to Ruby
          `sed -r "s#(.+)\|#\1|/$repo#" #{repo_log} >> combo.log`

          File.delete repo_log

          # username_map[repo.owner.login] = repo.owner.name
        end

        # sort by date - mix in combined repos.
        # TODO: Rewrite to Ruby
        `cat combo.log |sort -n >x.log`
        `mv x.log combo.log`

        # fix username mapping
        username_map.each do |_name, _fixed_name|
          `cat combo.log |sed "s/|$k|/|${user_fix[$k]}|/" >x.log`
          `mv x.log combo.log`
        end

        # keep langs, ignore .md update noise.
        # mv combo.log all.log
        # cat all.log |grep -E "\.(py|java|R|r|ipynb|scala|sh|sql|cs|js|do|hs)$" >combo.log

        # get github avatars
        # for user in $(cat combo.log |awk -F '|' '{print $2}' |sort |uniq) ;do
        #   if [ ! -f tmp/avatars/$user.jpg ] ;then
        #     curl -s -L "https://github.com/$user.png?size=512" -o tmp/avatars/$user.jpg
        #   fi
        # done

        # summary + dump to combo.csv for other purposes..
        # cat combo.log |awk -F '|' '{print $2}' |sort |uniq -c |sort -n -r
        # cat combo.log |sed 's/|/,/g; s/\///; s/\//,/;' >combo.csv
      end

      def github_client(credentials)
        if credentials.key? :access_token
          puts 'Authorizing with GitHub using access token.'
          client = Octokit::Client.new(access_token: credentials[:access_token])
        elsif credentials.key? :netrc
          puts 'Authorizing with GitHub using netrc.'
          client = Octokit::Client.new(netrc: true)
          client.login
        else
          puts 'Authorizing with GitHub using username and password.'
          client = Octokit::Client.new(login: credentials[:login], password: credentials[:password])
          # Exchange username, password and two factor code for an access
          # token if a two factor code is provided.
          if credentials.key? :two_factor_code
            client.create_authorization(
              scopes: ['repo'],
              note: 'gource_combinator',
              headers: { 'X-GitHub-OTP' => credentials[:two_factor_code] }
            )
          end
        end

        client
      end
    end
  end
end

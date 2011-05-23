# -*- coding: utf-8 -*-

self_file =
  if File.symlink?(__FILE__)
    require 'pathname'
    Pathname.new(__FILE__).realpath
  else
    __FILE__
  end
$:.unshift(File.dirname(self_file) + "/../lib")

require 'bundler/setup'
require 'shikoku'

Shikoku::GithubCrawler.each{ |git_url|
  puts git_url
  repos = Shikoku::Repository.new_from_remote git_url
  begin
    repos.setup
    repos.entries.each{ |entry|
      begin
        next if entry.kind_of? Grit::Submodule
        next if entry.tokenizer.kind_of? Shikoku::Tokenizer::Null
        p [repos.local_path, entry.path, entry.mime_type]
        entry.save_tokens
      rescue => error
        p [error, error.message]
      end
    }
  rescue => error
    p error
  end
}

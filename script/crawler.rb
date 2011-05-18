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
    rescue => error
    p error
  end
}

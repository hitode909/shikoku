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
require 'pp'

repos = Shikoku::Repository.new_from_remote "git://github.com/hitode909/kindairb.git"

repos.entries.each{ |f|
  f.tokenize
}

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

Shikoku::Repository.all.each{ |repos|
  p repos.entries.map(&:mime_type).uniq.sort
  repos.entries.each{ |entry|
    p [entry.path, entry.mime_type]
    entry.save_tokens
  }
}

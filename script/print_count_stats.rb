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

token_collection = Shikoku::Database.collection('application/ruby')
summary_collection = Shikoku::Database.collection('application/ruby/summary')

summary_collection.find.each{ |entry|
  puts entry['count']
}

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

table = Hash.new{ 0 }

#summary_collection.find.to_a.sort# _by{ |entry| -entry['count']}.each{ |entry|
#   v = entry['value'].gsub(/\n/, '')
#   puts "#{v}\t#{entry['count']}"
# }

summary_collection.find.each{ |entry|
  table[entry['count']]+=1
}

table.keys.sort.each{ |k|
  puts "#{k}\t#{table[k]}"
}

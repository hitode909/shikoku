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

summary_collection.ensure_index([['value', Mongo::ASCENDING]])

total = token_collection.count

token_collection.find.each_with_index{ |token, index|
  value = token['value']
  p [index, total, index.to_f / total * 100] if index % 10000 == 0
  summary_collection.update(
    { :value => value},
    { :$inc => { :count => 1}},
    { :upsert => true}
    )
}

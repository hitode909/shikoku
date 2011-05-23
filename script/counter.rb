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

value = ARGV.first || 'class'

from = Time.now

collection = Shikoku::Database.collection('application/ruby')

total = collection.find.count
found = collection.find({
    'value' => value
  }).count

p [total, found]
p 100.0 * found / total

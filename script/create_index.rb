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

entry = Shikoku::Entry.new(nil, nil)
entry.instance_variable_set(:@mime_type, 'application/ruby')
p entry
entry.create_index

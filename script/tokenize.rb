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
}

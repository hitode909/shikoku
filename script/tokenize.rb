# -*- coding: utf-8 -*-

self_file =
  if File.symlink?(__FILE__)
    require 'pathname'
    Pathname.new(__FILE__).realpath
  else
    __FILE__
  end
$:.unshift(File.dirname(self_file) + "/../lib")

p 'setup'
require 'bundler/setup'
require 'shikoku'
p 'setup done'

total = Shikoku::Repository.all_path.length

Shikoku::Repository.all_path.each_with_index{ |path, index|
  repos = Shikoku::Repository.new_from_local path
  repos.entries.each{ |entry|
    begin
      next if entry.kind_of? Grit::Submodule
      next if entry.tokenizer.kind_of? Shikoku::Tokenizer::Null
      p [index / total.to_f * 100, repos.local_path, entry.path, entry.mime_type]
      entry.save_tokens
    rescue => error
      p [error, error.message]
    end
  }
}

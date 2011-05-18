# -*- coding: utf-8 -*-
require 'rubygems'
require 'bundler/setup'

module Shikoku
  # VERSION = File.read(File.join(File.dirname(__FILE__), '../VERSION')).strip.to_f

  require 'shikoku/utility'
  require 'shikoku/github_crawler'
  require 'shikoku/repository'
  require 'shikoku/tokenizer'
  require 'shikoku/entry'
#  require 'shikoku/parser'
end

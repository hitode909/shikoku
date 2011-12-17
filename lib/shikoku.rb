# -*- coding: utf-8 -*-
require 'rubygems'
require 'bundler/setup'

module Shikoku
  # VERSION = File.read(File.join(File.dirname(__FILE__), '../VERSION')).strip.to_f

  require 'shikoku/token'
  require 'shikoku/tokenizer'
  require 'shikoku/database'
end

$:.unshift(File.dirname(__FILE__))
$:.unshift(File.dirname(__FILE__) + '../lib')

require 'bundler/setup'
require 'sinatra/base'
require 'shikoku'
require 'app'

run ShikokuApp

require 'rubygems'
require 'bundler'

Bundler.require

require './push_server'
run Sinatra::Application

require 'rubygems'
require 'bundler'

Bundler.require

require './push_server.rb'
run Sinatra::Application

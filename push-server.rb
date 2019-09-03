#!/usr/bin/env ruby

require 'sinatra'

set :bind, '0.0.0.0'
set :port, 33333

$counter = 0
$time_start = Time.now
$last_restart = Time.now
$server_thread = Thread.new {}
$base_directory = Dir.pwd

def start_web_server
  puts "Starting server"
  $server_thread = Thread.new do
    `$(cd 0x42424242.in && JEKYLL_ENV=production bundle exec jekyll serve --host 0.0.0.0 --port 30000)`
  end
  puts "Started server"
end

start_web_server

def get_jekyll_pid
  `ps -aux | grep "jekyll serve"`.split(" ")[1]
end

get('/github-hook') do
  "Recieved #{$counter} posts from github since #{$time_start} <br> Last Restart #{$last_restart}"
end

post('/github-hook') do
  $counter += 1  
  puts "!!!!! killing #{get_jekyll_pid}"
  `kill -9 #{get_jekyll_pid}`
  $server_thread.join
  puts "!!!!!! KILLED!"
  `rm -rf 0x42424242.in`
  `git clone git@specialgithuburl.com:redcodefinal/0x42424242.in.git`
  `mv -f 0x42424242.in/0x42424242.in/* 0x42424242.in/`
  start_web_server
  $last_restart = Time.now
end

Signal.trap("INT") {
  `kill -9 #{get_jekyll_pid}`
  $server_thread.join
  exit
}

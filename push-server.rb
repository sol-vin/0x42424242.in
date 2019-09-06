require "sinatra"

# Bind this publicly so github's webhooks can POST
set :bind, '0.0.0.0'
set :port, 33333

# How many times has a rebuild been invoked?
$counter = 0
$time_start = Time.now
$last_restart = Time.now
$server_thread = Thread.new {}
$secret = "e426e187caad1698ff0e3228c240362839f61ff6"

def start_web_server
  $server_thread = Thread.new do
    `$(cd 0x42424242.in && bundle exec jekyll serve --host 0.0.0.0 --port 30000)`
  end
end

start_web_server

def get_jekyll_pid
  `ps -aux | grep "jekyll serve"`.split(" ")[1]
end

def verify_secret(payload_body)
  signature = 'sha1=' + OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), $secret, payload_body)
  begin
    match = Rack::Utils.secure_compare(signature, request.env['HTTP_X_HUB_SIGNATURE'])
    return halt 500, "Signatures didn't match!" unless match
  rescue
    return halt 500
  end
end

def kill_web_server
  `kill -9 #{get_jekyll_pid}`
  $server_thread.join
end

def restart_web_server(clean_and_download = false)
  kill_web_server
  if clean_and_download
    `rm -rf 0x42424242.in`
    `git clone git@github.local:redcodefinal/0x42424242.in.git`
    `mv -f 0x42424242.in/0x42424242.in/* 0x42424242.in/`
  end

  start_web_server
end

get('/github-hook') do
  "Recieved #{$counter} posts from github since #{$time_start} <br> Last Restart #{$last_restart}"
end

post('/github-hook') do
  request.body.rewind
  payload_body = request.body.read
  verify_secret payload_body

  restart_web_server(true)

  $counter += 1  
  $last_restart = Time.now
end

Signal.trap("INT") {
  kill_web_server
  exit
}

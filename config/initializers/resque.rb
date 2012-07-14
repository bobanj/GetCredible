require 'resque/server'
Resque::Server.use Rack::Auth::Basic do |username, password|
  username == 'givebrand'
  password == 'brand@give'
end

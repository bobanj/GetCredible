require 'resque/server'
Resque.before_fork = Proc.new { ActiveRecord::Base.establish_connection }
Resque::Server.use Rack::Auth::Basic do |username, password|
  username == 'givebrand'
  password == 'brand@give'
end

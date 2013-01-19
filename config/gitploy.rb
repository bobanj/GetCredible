require 'gitploy/script'

configure do |c|
  stage :staging do
    c.path = '/home/pringle/apps/staging.givebrand.com'
    # c.host = 'staging.givebrand.com'
    c.host = '78.47.21.125'
    c.user = 'pringle'
    c.local_branch = 'staging' # default is current branch
    c.remote_branch = 'master' # default is master
  end

  stage :production do
    c.path = '/home/pringle/apps/givebrand.com'
    # c.host = 'givebrand.com'
    c.host = '78.47.21.125'
    c.user = 'pringle'
    c.local_branch = 'master' # default is current branch
    c.remote_branch = 'master' # default is master
  end
end

setup do
  remote do
    run "mkdir -p #{config.path}"
    run "cd #{config.path} && git init"
    run "git config --bool receive.denyNonFastForwards false"
    run "git config receive.denyCurrentBranch ignore"
  end
end

deploy do
  push!
  remote do
    run "cd #{config.path}"
    run "git reset --hard"
    run "ruby -v"
    run "bundle install"
    # run "bundle exec rake db:migrate RAILS_ENV=production"
    # run "bundle exec rake assets:precompile"
    # run "touch tmp/restart.txt"
  end
end

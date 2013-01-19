source 'https://rubygems.org'

gem 'rails', '3.2.11'
gem 'unicorn', '4.2.0'

gem 'pg'
gem 'mysql2'
gem 'devise', '>= 2.0.0'
gem 'devise_invitable', '= 1.0.1'
gem "haml", ">= 3.0.0"
gem "haml-rails"
gem "jquery-rails"
gem 'simple_form'
gem 'country_select'
gem 'mini_magick'
gem 'carrierwave'
gem 'capistrano'
gem 'capistrano-ext'
gem 'will_paginate'
gem 'fog'
gem 'sass-rails'
gem 'bootstrap-sass'
gem 'compass-rails','~> 1.0.0.rc.3'
gem 'compass-960-plugin'
gem 'statistics2'
gem 'rankable_graph'
gem 'redis-objects'
gem 'redis-namespace'
gem 'rails_config'
gem 'soulmate'
gem 'newrelic_rpm'
gem 'remotipart', '~> 1.0'
gem 'omniauth'
gem 'omniauth-twitter'
gem 'omniauth-linkedin'
gem 'omniauth-facebook'
gem 'twitter'
gem 'linkedin'
gem 'koala'
gem 'xmpp4r_facebook'
gem 'exception_notification'
gem 'rinku', :require => 'rails_rinku'
gem 'resque'
gem 'foreman'

group :assets do
  gem 'coffee-rails', '~> 3.2.2'
  gem 'uglifier', '>= 1.2.3'
end

group :development do
  gem 'guard'
  gem 'random-word'
  gem 'guard-spork'
  gem 'rb-fsevent', :require => RUBY_PLATFORM.include?('darwin')  && 'rb-fsevent'
  gem 'growl',      :require => RUBY_PLATFORM.include?('darwin')  && 'growl'
  gem 'rb-inotify', :require => RUBY_PLATFORM.include?('linux')   && 'rb-inotify'
  gem 'libnotify',  :require => RUBY_PLATFORM.include?('linux')   && 'rb-inotify'
  gem 'rails3-generators'
  gem 'quiet_assets'
  # gem 'rails-footnotes', '>= 3.7.5.rc4'
  gem 'awesome_print', :require => 'ap'
  gem 'sqlite3'
end

group :test do
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'shoulda-matchers'
  gem 'spork', '~> 0.9.0.rc'
  gem 'launchy'
  gem 'capybara'
  gem 'capybara-webkit'
  gem 'email_spec'
end

group :development, :test do
  gem "rspec-rails", ">= 2.8.1"
  gem 'debugger'
end

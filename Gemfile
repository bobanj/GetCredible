source 'https://rubygems.org'

gem 'rails', '3.2.2'
gem 'unicorn', '4.2.0'

# Bundle edge Rails instead:
# gem 'rails', :git => 'git://github.com/rails/rails.git'

gem 'mysql2'
gem 'thumbs_up'

# Gems used only for assets and not required
# in production environments by default.
group :assets do
  gem 'sass-rails',   '~> 3.2.4'
  gem 'coffee-rails', '~> 3.2.2'

  # See https://github.com/sstephenson/execjs#readme for more supported runtimes
  # gem 'therubyracer'

  gem 'uglifier', '>= 1.2.3'
  gem 'bootstrap-sass', '~> 1.4.3'
  gem 'compass-rails','~> 1.0.0.rc.3'
  gem 'compass-960-plugin'
end

group :development do
  gem 'guard'
  # gem 'guard-cucumber'
  # gem 'guard-rspec'
  gem 'guard-spork'
  gem 'rb-fsevent', :require => RUBY_PLATFORM.include?('darwin')  && 'rb-fsevent'
  gem 'growl',      :require => RUBY_PLATFORM.include?('darwin')  && 'growl'
  gem 'rb-inotify', :require => RUBY_PLATFORM.include?('linux')   && 'rb-inotify'
  gem 'libnotify',  :require => RUBY_PLATFORM.include?('linux')   && 'rb-inotify'
  gem 'rb-readline'
end

group :test do
  gem 'database_cleaner'
  gem 'factory_girl_rails'
  gem 'shoulda-matchers'
  gem 'spork', '~> 0.9.0.rc'
end




# To use ActiveModel has_secure_password
# gem 'bcrypt-ruby', '~> 3.0.0'

# To use Jbuilder templates for JSON
# gem 'jbuilder'

# Use unicorn as the app server
# gem 'unicorn'

# Deploy with Capistrano
# gem 'capistrano'

# To use debugger
# gem 'ruby-debug19', :require => 'ruby-debug'

gem "capybara", :group => [:development, :test]
gem "devise"
gem "haml", ">= 3.0.0"
gem "haml-rails"
gem "jquery-rails"
gem "rspec-rails", ">= 2.8.1", :group => [:development, :test]
gem 'simple_form'

group :development do
  gem 'awesome_print'
  gem 'capistrano'
  gem 'capistrano-ext'
  gem 'hirb'
  gem 'rails3-generators'
  gem 'wirble'
end

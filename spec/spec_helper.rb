require 'rubygems'
require 'spork'

Spork.prefork do
  # Loading more in this block will cause your tests to run faster. However,
  # if you change any configuration or code from libraries loaded here, you'll
  # need to restart spork for it take effect.

  # This file is copied to spec/ when you run 'rails generate rspec:install'

  # This file is copied to spec/ when you run 'rails generate rspec:install'
  ENV["RAILS_ENV"] ||= 'test'
  require File.expand_path("../../config/environment", __FILE__)
  require 'rspec/rails'
  require 'rspec/autorun'
  require 'shoulda/matchers/integrations/rspec'

  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[Rails.root.join("spec/support/**/*.rb")].each {|f| require f}

  RSpec.configure do |config|
    # ## Mock Framework
    #
    # If you prefer to use mocha, flexmock or RR, uncomment the appropriate line:
    #
    # config.mock_with :mocha
    # config.mock_with :flexmock
    # config.mock_with :rr

    # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
    config.fixture_path = "#{::Rails.root}/spec/fixtures"

    # If you're not using ActiveRecord, or you'd prefer not to run each of your
    # examples within a transaction, remove the following line or assign false
    # instead of true.
    config.use_transactional_fixtures = true

    # If true, the base class of anonymous controllers will be inferred
    # automatically. This will be the default behavior in future versions of
    # rspec-rails.
    config.infer_base_class_for_anonymous_controllers = false

    # Devise test helpers
    config.include Devise::TestHelpers, :type => :controller
  end
end

Spork.each_run do
  # This code will be run each time you run your specs.

  # routes reload
  GetCredible::Application.reload_routes!

  # factories reload
  FactoryGirl.reload

  # models reload
  Dir["#{Rails.root}/app/models/**/*.rb"].each { |model| load model }

  load "Sporkfile.rb" if File.exists?("Sporkfile.rb")
end

def it_should_require_current_user_for(*actions)
  actions.each do |action|
    it "#{action} action should require current user" do
      get action, :id => 1 # so routes work for those requiring id
      controller.should_not_receive(action)
    end
  end
end

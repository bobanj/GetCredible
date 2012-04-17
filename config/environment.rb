# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
GetCredible::Application.initialize!

DOMAIN_URL = "http://#{ActionMailer::Base.default_url_options[:host]}"

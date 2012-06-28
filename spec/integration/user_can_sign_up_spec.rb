require 'spec_helper'
require_relative 'steps/app_steps'

describe 'User', type: :request do

  it "can sign up" do
    email = 'user@example.com'

    visit(root_path)
    within(".easy-signup") do
      fill_in("Username", with: "pink_panter")
      fill_in("Email", with: email)
      fill_in("Password", with: "password")
      click_button("Sign up")
    end
    page.should have_content('Welcome! You have signed up successfully.')

    user = User.find_by_email(email)
    # current_path.should == activity_path('all')

    unread_emails_for(email).size.should == parse_email_count(1)
    open_email(email)
    current_email.should have_subject("Welcome to GiveBrand!")
    current_email.body.should have_content("Dear pink_panter")
    current_email.body.should have_content("Welcome to GiveBrand!")
  end
end


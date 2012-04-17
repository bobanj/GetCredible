require 'spec_helper'
require_relative 'steps/app_steps'

describe 'User', type: :request do

  it "can sign up" do
    email = 'user@example.com'

    visit(root_path)
    click_link("Sign up")
    fill_in("Full name", with: "Some User")
    fill_in("Email", with: email)
    fill_in("Password", with: "password")
    click_button("Sign up")
    page.should have_content('Welcome! You have signed up successfully.')

    user = User.find_by_email(email)
    current_path.should == all_user_path(user)

    unread_emails_for(email).size.should == parse_email_count(1)
    open_email(email)
    current_email.should have_subject("[GiveBrand] Welcome")
    current_email.should have_content("Welcome Some User")
  end
end


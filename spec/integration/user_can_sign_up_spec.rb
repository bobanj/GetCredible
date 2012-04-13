require 'spec_helper'
require_relative 'steps/app_steps'

describe 'User', type: :request do

  it "can sign up" do
    visit(root_path)
    click_link("Sign up")
    fill_in("Full name", with: "Some User")
    fill_in("Email", with: "user@example.com")
    fill_in("Password", with: "password")
    click_button("Sign up")
    page.should have_content('Welcome! You have signed up successfully.')
  end
end


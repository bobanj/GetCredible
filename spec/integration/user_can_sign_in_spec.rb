require 'spec_helper'
require_relative 'steps/app_steps'

describe 'User', type: :request do

  it "can sign in with email and sign out" do
    user = Factory :user
    visit root_path
    click_link("Login")
    fill_in("Email or Username", with: user.email)
    fill_in("Password", with: user.password)
    click_button("Sign in")
    page.should have_content("Signed in successfully.")
    click_link('Logout')
    page.should have_content('Signed out successfully.')
  end

  it "can sign in with username" do
    user = Factory :user
    visit root_path
    click_link("Login")
    fill_in("Email or Username", with: user.username)
    fill_in("Password", with: user.password)
    click_button("Sign in")
    page.should have_content("Signed in successfully.")
  end
end


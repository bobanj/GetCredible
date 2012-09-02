require 'spec_helper'

describe 'User', type: :request do

  it "can sign in with email and sign out" do
    user = FactoryGirl.create(:user)
    visit root_path
    within("#user_sign_in") do
      fill_in("Email or Username", with: user.email)
      fill_in("Password", with: user.password)
      click_button("Sign in")
    end
    page.should have_content("Logout")
    click_link('Logout')
    page.should_not have_content('Logout')
  end

  it "can sign in with username" do
    user = FactoryGirl.create(:user)
    visit root_path
    within("#user_sign_in") do
      fill_in("Email or Username", with: user.username)
      fill_in("Password", with: user.password)
      click_button("Sign in")
    end
    page.should have_content("Logout")
  end
end

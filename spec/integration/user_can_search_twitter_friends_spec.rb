require 'spec_helper'
require_relative 'steps/app_steps'

describe 'User', type: :request do

  it "can search twitter friends", js: true do
    user = FactoryGirl.create(:user, full_name: "Some Name")
    twitter_contact = FactoryGirl.create(:twitter_contact, twitter_id: 1,
      screen_name: 'green_panter', name: 'Green Panter', user: user)
    twitter_contact = FactoryGirl.create(:twitter_contact, twitter_id: 2,
      screen_name: 'pink_panter', name: 'Pink Panter', user: user)

    sign_in_user(user)
    within("#global-nav") do
      click_link("Invite")
    end

    page.should have_content("green_panter")
    page.should have_content("pink_panter")

    within("#main") do
      fill_in("Search", with: "green")
      click_button("Search")

      page.should have_content("green_panter")
      page.should_not have_content("pink_panter")

      fill_in("Search", with: "pink")
      click_button("Search")

      page.should have_content("pink_panter")
      page.should_not have_content("green_panter")

      fill_in("Search", with: "")
      click_button("Search")

      page.should have_content("pink_panter")
      page.should have_content("green_panter")
    end
  end
end

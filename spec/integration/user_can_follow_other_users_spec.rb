require 'spec_helper'

describe 'User', type: :request do

  it "can follow other users", js: true do
    follower = FactoryGirl.create(:user, full_name: "Follower")
    user = FactoryGirl.create(:user, full_name: "Pink Panter")
    sign_in_user(follower)

    visit user_path(user)

    page.should have_content("0 Following")
    page.should have_content("0 Followers")

    # follow
    within("#profile") do
      click_button("Follow")
    end

    page.should have_content("0 Following")
    page.should have_content("1 Followers")

    # unfollow
    within("#profile") do
      page.execute_script("$('.js-friendship-action').trigger('mouseover')")
      click_button("Unfollow")
    end

    within("#friend-nav") do
      page.should have_content("0 Following")
      page.should have_content("0 Followers")
    end

    within("#profile") do
      click_button("Follow")
    end

    # unfollow from my profile page
    click_link("Profile")
    click_link("1 Following")

    within("#invitation_content") do
      page.execute_script("$('.js-friendship-action').trigger('mouseover')")
      click_button("Unfollow")
    end

    within("#friend-nav") do
      page.should have_content("0 Following")
      page.should have_content("0 Followers")
    end
  end
end

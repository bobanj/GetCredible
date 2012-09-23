require 'spec_helper'

describe 'User', type: :request do

  it "can follow other users", js: true do
    follower = FactoryGirl.create(:user, full_name: "Pink Panther")
    user = FactoryGirl.create(:user, email: 'naruto@example.com', full_name: "Uzumaki Naruto")
    sign_in_user(follower)

    visit user_path(user)

    page.should have_content("0 Following")
    page.should have_content("0 Followers")

    # follow
    within("#profile") do
      click_button("Follow")
    end

    visit user_path(user)
    page.should have_content("0 Following")
    page.should have_content("1 Followers")

    open_email(user.email)
    current_email.should have_subject("Somebody's following you on GiveBrand!")
    current_email.body.should have_content("Don't worry! The more people who see your skills and personality, the closer you are to landing that dream gig.")

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
    click_link("Pink Panther")
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

require 'spec_helper'

describe 'User', type: :request do

  it "can accept email invitation", js: true do
    mock_send_message # mock twitter integration

    user = FactoryGirl.create(:user, full_name: "Some Name")
    authentication = FactoryGirl.create(:authentication, user: user)
    contact = FactoryGirl.create(:contact, uid: 1,
                screen_name: 'twitter_user', name: 'Ninja')
    FactoryGirl.create(:authentication_contact, contact: contact, authentication: authentication)

    sign_in_user(user)
    within("#global-nav") do
      click_link("Invite")
    end
    within(".twitter-contacts-list") do
      click_link("Invite")
    end

    # invite user
    within("#js-invitation-message-form") do
      fill_in("First tag", with: "tag1")
      fill_in("Second tag", with: "tag2")
      click_button("Send Message")
    end
    page.should have_content("An invitation message has been sent to #{contact.name}")

    click_link("Logout")

    invited = user.followings.first
    visit "/users/invitation/accept?invitation_token=#{invited.invitation_token}"

    within("#content") do
      page.should have_content("tag1")
      page.should have_content("tag2")
      # page.should have_content("Some Name")
      page.should have_xpath("//img[@title=\"Some Name\"]")
    end

    click_button("Save")
    within(".input.email") do
      page.should have_content("can't be blank")
    end

    fill_in("Username", with: "twitter_user")
    fill_in("Email", with: "twitter_user@example.com")
    fill_in("Password", with: "password")
    click_button("Save")
    page.should have_content("Your have joined GiveBrand!")
  end
end

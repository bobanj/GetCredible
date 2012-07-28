require 'spec_helper'

describe 'User', type: :request do

  it "can invite users via twitter", js: true do
    mock_send_message # mock twitter integration

    user = FactoryGirl.create(:user, full_name: "Some Name")
    authentication = FactoryGirl.create(:authentication, user: user)
    contact = FactoryGirl.create(:contact, :screen_name => 'twitter_user', :name => 'Ninja')
    FactoryGirl.create(:authentication_contact, contact: contact, authentication: authentication)

    sign_in_user(user)
    click_link("Invite and Tag Your Contacts")
    within(".twitter-contacts-list") do
      click_link("Invite")
    end

    # see error messages
    within("#js-invitation-message-form") do
      click_button("Send Message")
      page.should have_content("add at least one tag")
    end
    page.should have_content('We could not sent your message at this time.')

    # invite user
    within("#js-invitation-message-form") do
      fill_in("First tag", with: "tag1")
      fill_in("Second tag", with: "tag2")
      click_button("Send Message")
    end
    page.should have_content("An invitation message has been sent to #{contact.name}." )

    invited = User.find_by_email('twitter_1')
    user.followings.should include(invited)
  end
end

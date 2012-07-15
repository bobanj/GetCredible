require 'spec_helper'
require_relative 'steps/app_steps'

describe 'User', type: :request do

  it "can invite users via twitter", js: true do
    # mock twitter integration
    InvitationMessage.any_instance.should_receive(:send_invitation_message).and_return(true)
    InvitationMessage.any_instance.should_receive(:get_avatar_url).and_return(nil)

    user = FactoryGirl.create(:user, full_name: "Some Name")
    twitter_contact = FactoryGirl.create(:twitter_contact,
                        :screen_name => 'twitter_user', user: user)

    sign_in_user(user)
    within("#global-nav") do
      click_link("Invite")
    end
    within(".twitter-contacts-list") do
      click_link("Invite")
    end

    # see error messages
    within("#js-invitation-message-form") do
      click_button("Send Direct Message")
      page.should have_content("add at least one tag")
    end
    page.should have_content('We could not sent your message at this time.')

    # invite user
    within("#js-invitation-message-form") do
      fill_in("First tag", with: "tag1")
      fill_in("Second tag", with: "tag2")
      click_button("Send Direct Message")
    end
    page.should have_content('An invitation message has been sent to @twitter_user.')

    invited = User.find_by_email('twitter_1')
    user.followings.should include(invited)
  end
end

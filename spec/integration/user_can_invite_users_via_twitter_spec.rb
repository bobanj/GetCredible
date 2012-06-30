require 'spec_helper'
require_relative 'steps/app_steps'

describe 'User', type: :request do

  it "can invite users via twitter", js: true do
    # mock twitter integration
    TwitterMessage.any_instance.should_receive(:send_twitter_message).and_return(true)

    user = FactoryGirl.create(:user, full_name: "Some Name")
    twitter_contact = FactoryGirl.create(:twitter_contact,
                        :screen_name => 'twitter_user', user: user)

    sign_in_user(user)
    click_link("Invite & Tag")
    within(".twitter-contacts-list") do
      click_link("Invite")
    end

    # see error messages
    within("#js-twitter-invitation-form") do
      click_button("Send Direct Message")
      page.should have_content("add at least one tag")
    end
    page.should have_content('We could not sent your message at this time.')

    # invite user
    within("#js-twitter-invitation-form") do
      fill_in("First tag", with: "tag1")
      fill_in("Second tag", with: "tag2")
      click_button("Send Direct Message")
    end
    page.should have_content('An invitation message has been sent to @twitter_user.')

    invited = User.find_by_email('twitter_1')
    user.followings.should include(invited)
  end
end

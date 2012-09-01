require 'spec_helper'

describe 'User', type: :request do

  it "can delete their own endorsements", js: true do
    endorser = FactoryGirl.create(:user, full_name: "Endorser")
    user = FactoryGirl.create(:user, full_name: "Pink Panther")
    tag = FactoryGirl.create(:tag)
    user_tag = FactoryGirl.create(:user_tag, user: user, tagger: endorser, tag: tag)
    endorsement = FactoryGirl.create(:endorsement, endorser: endorser,
                     user_tag: user_tag, description: "This is my endorsement")

    sign_in_user(user)

    visit user_path(user)

    page.should have_content("This is my endorsement")

    within(".js_endorsement") do
      click_link("X")
    end
    page.should_not have_content("This is my endorsement")
  end
end

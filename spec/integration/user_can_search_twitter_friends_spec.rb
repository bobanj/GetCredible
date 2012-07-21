require 'spec_helper'

describe 'User', type: :request do

  it "can search twitter friends", js: true do
    user = FactoryGirl.create(:user, full_name: "Some Name")
    authentication = FactoryGirl.create(:authentication, user: user)
    contact = FactoryGirl.create(:contact, uid: 1,
      screen_name: 'green_panter', name: 'Green Panter', authentication: authentication)
    contact = FactoryGirl.create(:contact, uid: 2,
      screen_name: 'pink_panter', name: 'Pink Panter', authentication: authentication)

    sign_in_user(user)
    within("#global-nav") do
      click_link("Invite")
    end

    page.should have_content("Green Panter")
    page.should have_content("Pink Panter")

    within("#main") do
      fill_in("Search", with: "green")
      click_button("Search")

      page.should have_content("Green Panter")
      page.should_not have_content("Pink Panter")

      fill_in("Search", with: "pink")
      click_button("Search")

      page.should have_content("Pink Panter")
      page.should_not have_content("Green Panter")

      fill_in("Search", with: "")
      click_button("Search")

      page.should have_content("Pink Panter")
      page.should have_content("Green Panter")
    end
  end
end

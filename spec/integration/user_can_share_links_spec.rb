require 'spec_helper'

describe 'User', type: :request do

  it "can share links", js: true do
    user1 = FactoryGirl.create(:user)
    user2 = FactoryGirl.create(:user, full_name: 'Pink Panther')
    tag = FactoryGirl.create(:tag, name: 'rails')
    user2.add_tags(user1, ['rails'])
    user1.follow(user2)

    sign_in_user(user2)
    click_link("Activity")

    within("#share_link") do
      fill_in("Web page link", with: "http://example.com/ruby-article.html")
      fill_in("Tags", with: "ruby, language")
      click_button("Share")
    end
    page.should have_content("Successfully shared")

    within("#share_link") do
      fill_in("Web page link", with: "http://example.com/rails-article.html")
      fill_in("Tags", with: "rails, framework")
      click_button("Share")
    end
    page.should have_content("Successfully shared")

    click_link("Logout")

    sign_in_user(user1)
    click_link("Activity")

    page.should_not have_content("Pink Panther shared a link http://example.com/ruby-article.html")
    page.should have_content("Pink Panther shared a link http://example.com/rails-article.html")
  end
end

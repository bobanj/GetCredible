require 'spec_helper'

describe 'User', type: :request do

  it "can share links" do
    user1 = FactoryGirl.create(:user)
    user2 = FactoryGirl.create(:user, full_name: 'Pink Panter')
    tag = FactoryGirl.create(:tag, name: 'rails')
    user2.add_tags(user1, ['rails'])
    user1.follow(user2)

    sign_in_user(user2)
    click_link("Activity")

    within(".share_link") do
      fill_in("Url", with: "http://example.com/ruby-article.html")
      fill_in("Tags", with: "ruby, language")
      click_button("Share")
    end
    page.should have_content("You shared a link http://example.com/ruby-article.html tags: ruby, language")

    within(".share_link") do
      fill_in("Url", with: "http://example.com/rails-article.html")
      fill_in("Tags", with: "rails, framework")
      click_button("Share")
    end
    page.should have_content("You shared a link http://example.com/rails-article.html tags: rails, framework")

    click_link("Logout")

    sign_in_user(user1)
    click_link("Activity")

    page.should_not have_content("Pink Panter shared a link http://example.com/ruby-article.html tags: ruby, language")
    page.should have_content("Pink Panter shared a link http://example.com/rails-article.html tags: rails, framework")
  end
end

require 'spec_helper'

describe 'User', type: :request do

  it "can share links" do
    # user 1 exists with tag 'rails'
    # user 1 follows user 2
    user1 = FactoryGirl.create(:user)
    user2 = FactoryGirl.create(:user, full_name: 'Pink Panter')
    tag = FactoryGirl.create(:tag, name: 'rails')
    user2.add_tags(user1, ['rails'])
    user1.follow(user2)

    # user 2 login
    sign_in_user(user2)
    click_link("Activity")

    # user 2 share link 2: ruby, language
    within(".share_link") do
      fill_in("Url", with: "http://example.com/ruby-article.html")
      fill_in("Tags", with: "ruby, language")
      click_button("Share")
    end
    page.should have_content("You shared a link http://example.com/ruby-article.html tags: ruby, language")

    # user 2 share link 1: rails, framework
    within(".share_link") do
      fill_in("Url", with: "http://example.com/rails-article.html")
      fill_in("Tags", with: "rails, framework")
      click_button("Share")
    end
    page.should have_content("You shared a link http://example.com/rails-article.html tags: rails, framework")

    # user 2 logout
    click_link("Logout")

    # user 1 login
    sign_in_user(user1)
    click_link("Activity")

    # user 1 should see only the rails link
    page.should_not have_content("Pink Panter shared a link http://example.com/ruby-article.html tags: ruby, language")
    page.should have_content("Pink Panter shared a link http://example.com/rails-article.html tags: rails, framework")
  end
end

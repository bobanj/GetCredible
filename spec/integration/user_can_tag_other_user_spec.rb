require 'spec_helper'
require_relative 'steps/app_steps'

describe 'User', type: :request do

  it "can tag other user" do
    user = Factory :user, full_name: "User"
    other_user = Factory :user, full_name: "Other User"
    sign_in_user(user)

    visit(me_user_path(other_user))
    fill_in("Add Tags", with: "developer, designer")
    click_button("ADD TAG")

    tags = other_user.tags
    tags.length.should == 2

    tag_names = tags.map(&:name)
    tag_names.should include("developer")
    tag_names.should include("designer")

    user_tags = other_user.user_tags
    user_tags.length.should == 2

    # it creates vote for each tag
    user_tags[0].votes.length.should == 1
    user_tags[1].votes.length.should == 1

    unread_emails_for(other_user.email).size.should == parse_email_count(1)
    open_email(other_user.email)
    current_email.should have_subject("[GiveBrand] You have been tagged!")
    current_email.should have_content("User tagged you with: developer, designer ")
  end
end


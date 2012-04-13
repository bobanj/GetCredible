require 'spec_helper'
require_relative 'steps/app_steps'

describe 'User', type: :request do

  it "can edit their account" do
    user = Factory :user, full_name: "Some Name"
    sign_in_user(user)
    click_link("Profile")
    click_link("Edit profile")
    fill_in("Full name", with: "Some other Name")
    click_button("Save")
    page.should have_content("You have updated your profile successfully.")

    click_link("Profile")
    click_link("Edit profile")
    find_field("Full name").value.should == "Some other Name"
  end
end


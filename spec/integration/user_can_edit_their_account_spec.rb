require 'spec_helper'
require_relative 'steps/app_steps'

describe 'User', type: :request do

  it "can edit their account" do
    user = FactoryGirl.create(:user, full_name: "Some Name")
    sign_in_user(user)
    click_link("Profile")
    click_link("Edit")
    fill_in("Full name", with: "Some other Name")
    click_button("Save")
    page.should have_content("You have updated your profile successfully.")

    click_link("Profile")
    click_link("Edit")
    find_field("Full name").value.should == "Some other Name"
  end
end


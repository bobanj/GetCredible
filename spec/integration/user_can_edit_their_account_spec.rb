require 'spec_helper'

describe 'User', type: :request do

  it "can edit their account" do
    user = FactoryGirl.create(:user, full_name: "Some Name")
    sign_in_user(user)
    click_link("Activity")
    within ".my-actions" do
      click_link(user.short_name)
    end
    fill_in("Full name", with: "Some other Name")
    click_button("Save")
    page.should have_content("You have updated your profile successfully.")

    click_link("Profile")
    within ".details" do
      find("h1", :text => "Some other Name")
    end

    within ".my-actions" do
      click_link(user.short_name)
    end
    find_field("Full name").value.should == "Some other Name"
  end
end


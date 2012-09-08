require 'spec_helper'

describe 'User', type: :request do

  it "can edit their account" do
    user = FactoryGirl.create(:user, full_name: "Pink Panther")
    sign_in_user(user)
    click_link('Pink Panther')
    click_link('Edit Profile')
    fill_in("Full name", with: "Green Panther")
    click_button("Save")
    page.should have_content("You have updated your profile successfully.")

    click_link('Green Panther')
    within ".details" do
      find("h1", :text => "Green Panther")
    end

    click_link('Green Panther')
    find_field("Full name").value.should == "Green Panther"
  end
end


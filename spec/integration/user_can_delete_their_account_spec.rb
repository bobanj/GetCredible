require 'spec_helper'

describe 'User', type: :request do

  it "can delete their account" do
    user = FactoryGirl.create(:user, full_name: "Pink Panther")
    sign_in_user(user)
    click_link('Edit Profile')
    click_link("Delete my account")
    page.should have_content("Bye! Your account was successfully deleted. We hope to see you again soon.")
  end
end


require 'spec_helper'

describe 'User', type: :request do

  it "can cancel their account" do
    user = FactoryGirl.create(:user, full_name: "Pink Panther")
    sign_in_user(user)
    click_link('Pink Panther')
    within "#profile" do
      click_link("Edit")
    end
    click_link("Cancel my account")
    page.should have_content("Bye! Your account was successfully cancelled. We hope to see you again soon.")
  end
end


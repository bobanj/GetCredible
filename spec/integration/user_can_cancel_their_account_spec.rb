require 'spec_helper'
require_relative 'steps/app_steps'

describe 'User', type: :request do

  it "can cancel their account" do
    user = FactoryGirl.create(:user, full_name: "Some Name")
    sign_in_user(user)
    within ".my-actions" do
      click_link(user.short_name)
    end
    click_link("Cancel my account")
    page.should have_content("Bye! Your account was successfully cancelled. We hope to see you again soon.")
  end
end


require 'spec_helper'
require_relative 'steps/app_steps'

describe 'User', type: :request do

  it "can sign in and sign out" do
    user = Factory :user, full_name: "Some Name"
    sign_in_user(user)
    current_path.should == all_user_path(user)
    click_link('Logout')
    page.should have_content('Signed out successfully.')
  end
end


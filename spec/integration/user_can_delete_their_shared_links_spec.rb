require 'spec_helper'

describe 'User', type: :request do

  it "can delete their shared links" do
    user = FactoryGirl.create(:user)
    FactoryGirl.create(:link, user: user, title: 'Ruby is great',
                       tag_names: 'ruby, language')

    sign_in_user(user)
    click_link("Profile")
    click_link("1 Share")

    page.should have_content('Ruby is great')
    within("#links .link_details") do
      click_link("Delete")
    end

    page.should have_content("Link was successfully deleted")
    page.should_not have_content('Ruby is great')
  end
end

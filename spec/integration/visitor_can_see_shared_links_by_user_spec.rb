require 'spec_helper'

describe 'Visitor', type: :request do

  it "can see shared links by user" do
    user = FactoryGirl.create(:user)
    FactoryGirl.create(:link, user: user, title: 'Ruby is great',
                       tag_names: 'ruby, language')

    visit(me_user_path(user))
    click_link("1 Share")

    within("#links .link_details") do
      find('a').text.should == 'Ruby is great'
      find('a')['href'].should == "http://www.example.com"
    end

    within("#links .link_tags") do
      page.should have_content('ruby')
      page.should have_content('language')
    end
  end
end

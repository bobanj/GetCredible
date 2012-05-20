require 'spec_helper'

describe HomeController do

  describe "#index" do
    it "returns http success" do
      get :index

      response.should render_template('index')
    end

    it "redirect to all activities if user is logged in" do
      user = FactoryGirl.create(:user)
      sign_in(user)

      get :index
      response.should redirect_to(activity_path('all'))
    end
  end

end

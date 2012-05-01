require 'spec_helper'

describe TagsController do

  describe "POST 'search'" do
    it "returns http success" do
      post 'search'
      response.should be_success
    end
  end

end

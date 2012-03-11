require 'spec_helper'

describe UsersController do

  describe "#index" do
    it "can respond to index" do
      User.should_receive(:search).and_return(stub)
      get :index
      response.should be_success
    end
  end

  describe "#show" do
    it "can respond to show" do
      User.should_receive(:find).with('1').and_return(stub)
      get :show, :id => '1'
      response.should be_success
    end
  end

end

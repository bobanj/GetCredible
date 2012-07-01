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
      user = mock_model(User)
      User.should_receive(:find_by_username!).with('some-name').and_return(user)
      user.stub_chain(:user_tags, :includes).and_return([])
      get :show, :id => 'some-name'
      response.should be_success
    end
  end
end

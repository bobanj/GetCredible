require 'spec_helper'

describe UserTagsController do

  describe "#index" do
    it "returns user tags" do
      user = stub(:user, :tags_summary => [])
      User.stub(:find).with('1').and_return(user)

      get :index, format: 'json', :user_id => '1'
      JSON.parse(response.body).should be_empty
    end
  end

  describe "#create" do
    let(:user) { Factory(:user) }

    it "requires signed in user" do
      controller.should_not_receive(:create)
      user.should_not_receive(:add_tags)
      post :create, tag_names: 'something'
    end

    it "can tag other user" do
      sign_in(user)
      other_user = Factory.build(:user)
      User.stub(:find).with('1').and_return(other_user)

      other_user.should_receive(:add_tags).with('something')
      post :create, tag_names: 'something', user_id: 1, format: 'json'
    end

    it "cannot tag himself" do
      sign_in(user)
      User.stub(:find).with('1').and_return(user)

      user.should_not_receive(:add_tags).with('something')
      post :create, tag_names: 'something', user_id: 1, format: 'json'
    end
  end
end

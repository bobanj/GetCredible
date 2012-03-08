require 'spec_helper'

describe TagsController do

  describe "#create" do
    let(:user) { Factory(:user) }

    before :each do
      User.stub(:find).with('1').and_return(user)
    end

    it "requires signed in user" do
      controller.should_not_receive(:create)
      user.should_not_receive(:tag)
      post :create, tag_names: 'something'
    end

    it "can tag user when signed in" do
      sign_in(user)
      user.should_receive(:tag).with('something')
      post :create, tag_names: 'something', user_id: 1, format: 'json'
    end
  end
end

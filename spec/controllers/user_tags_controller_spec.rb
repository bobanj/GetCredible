require 'spec_helper'

describe UserTagsController do

  describe "Authentication" do
    it_should_require_current_user_for :create, :vote, :unvote
  end

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
      UserTag.should_not_receive(:add_tags)
      post :create, tag_names: 'something'
    end

    it "can tag other user" do
      sign_in(user)
      other_user = Factory.build(:user)
      User.stub(:find).with('1').and_return(other_user)

      UserTag.should_receive(:add_tags).with(other_user, user, 'something')
      post :create, tag_names: 'something', user_id: 1, format: 'json'
    end

    it "cannot tag himself" do
      sign_in(user)
      User.stub(:find).with('1').and_return(user)

      UserTag.should_not_receive(:add_tags)
      post :create, tag_names: 'something', user_id: 1, format: 'json'
    end
  end

  describe "#vote" do
    let(:user) { Factory(:user) }

    before :each do
      sign_in(user)
      controller.stub(:current_user).and_return(user)
    end

    it "can vote for a user tag" do
      other_user = Factory(:user)
      user_tag   = Factory.build(:user_tag, :user => other_user)
      UserTag.stub(:find).with("1").and_return(user_tag)

      user.should_receive(:vote_exclusively_for).with(user_tag)

      post :vote, :user_id => user.id, :id => "1"
      JSON.parse(response.body)['status'].should == 'ok'
    end

    it "cannot vote for himself" do
      user_tag = Factory.build(:user_tag, :user => user)
      UserTag.stub(:find).with("1").and_return(user_tag)

      user.should_not_receive(:vote_exclusively_for).with(user_tag)

      post :vote, :user_id => user.id, :id => "1"
      JSON.parse(response.body)['status'].should == 'error'
    end
  end

  describe "#unvote" do

    let(:user) { Factory(:user) }

    before :each do
      sign_in(user)
      controller.stub(:current_user).and_return(user)
    end

    it "can vote for a user tag" do
      vote     = Factory.build(:vote)
      user_tag = Factory.build(:user_tag, user: user)
      UserTag.stub(:find).with("1").and_return(user_tag)
      user_tag.stub_chain(:votes, :for_voter, :first).and_return(vote)

      vote.should_receive(:destroy)

      post :unvote, :user_id => user.id, :id => "1"
      JSON.parse(response.body)['status'].should == 'ok'
    end
  end
end

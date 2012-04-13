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

      UserTag.should_receive(:add_tags).with(other_user, user, ['something'])
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
    let(:user) { Factory(:user, full_name: 'User') }
    let(:other_user) { Factory.build(:user) }
    let(:tag) { Factory.build(:tag) }

    before :each do
      sign_in(user)
      controller.stub(:current_user).and_return(user)
    end

    it "can vote for a user tag" do
      user_tag   = Factory.build(:user_tag, :user => other_user,
                                 :tag => Factory(:tag, name: 'developer'))
      User.stub(:find).and_return(other_user)
      other_user.stub_chain(:user_tags, :find).with("1").and_return(user_tag)

      user.should_receive(:add_vote).with(user_tag).and_return(true)

      post :vote, :user_id => other_user.id, :id => "1"
      JSON.parse(response.body)['status'].should == 'ok'

      unread_emails_for(other_user.email).size.should == parse_email_count(1)
      open_email(other_user.email)
      current_email.should have_subject("[GiveBrand] You received a vote!")
      current_email.should have_content("User vouched for developer")
    end

    it "cannot vote for himself" do
      user_tag = Factory.build(:user_tag, :user => user)
      User.stub(:find).and_return(other_user)
      other_user.stub_chain(:user_tags, :find).with("1").and_return(user_tag)

      user.should_receive(:add_vote).with(user_tag).and_return(false)

      post :vote, :user_id => user.id, :id => "1"
      JSON.parse(response.body)['status'].should == 'error'

      unread_emails_for(user.email).size.should == parse_email_count(0)
    end
  end

  describe "#unvote" do
    let(:user) { Factory(:user, full_name: 'User') }
    let(:other_user) { Factory.build(:user) }
    let(:tag) { Factory.build(:tag) }

    before :each do
      sign_in(user)
      controller.stub(:current_user).and_return(user)
    end

    it "can remove vote from a user tag" do
      user_tag = Factory.build(:user_tag, tagger: user, tag: tag)
      User.stub(:find).and_return(other_user)
      other_user.stub_chain(:user_tags, :find).with("1").and_return(user_tag)
      user.should_receive(:remove_vote).and_return(true)

      post :unvote, :user_id => other_user.id, :id => "1"
      JSON.parse(response.body)['status'].should == 'ok'
    end

    it "cannot remove vote from a user tag is it does not exists" do
      user_tag = Factory.build(:user_tag, user: user)
      User.stub(:find).and_return(other_user)
      UserTag.stub(:find).with("1").and_return(user_tag)
      other_user.stub_chain(:user_tags, :find).with("1").and_return(user_tag)
      user.should_receive(:remove_vote).and_return(false)

      post :unvote, :user_id => other_user.id, :id => "1"
      JSON.parse(response.body)['status'].should == 'error'
    end
  end
end

require 'spec_helper'

describe UserTagsController do
  let(:user) { FactoryGirl.create(:user, full_name: 'User', username: 'user') }
  let(:other_user) { FactoryGirl.create(:user, full_name: "Other User", username: 'other_user') }

  describe "Authentication" do
    it_should_require_current_user_for :create, :vote, :unvote
  end

  describe "#index" do
    it "returns user tags" do
      User.stub(:find_by_username!).with(user.username).and_return(user)
      controller.stub(:tags_summary).with(user, nil).and_return([])

      get :index, format: 'json', :user_id => user.username
      JSON.parse(response.body).should be_empty
    end
  end

  describe "#create" do
    it "requires signed in user" do
      controller.should_not_receive(:create)
      post :create, tag_names: 'something'
    end

    it "can tag other user" do
      sign_in(user)

      controller.stub(:current_user).and_return(user)
      User.stub(:find_by_username!).with(other_user.username).and_return(other_user)

      user.should_receive(:add_tags).with(other_user, ['something'])
      post :create, tag_names: 'something', user_id: other_user.username, format: 'json'
    end

    it "can tag himself" do
      sign_in(user)

      controller.stub(:current_user).and_return(user)
      User.stub(:find_by_username!).with(other_user.username).and_return(user)

      user.should_receive(:add_tags)
      post :create, tag_names: 'something', user_id: other_user.username, format: 'json'
    end

    it "automatically sends email and votes when tagging" do
      sign_in(user)

      post :create, tag_names: "developer, designer", user_id: other_user.username, format: 'json'

      tags = other_user.tags
      tags.length.should == 2

      tag_names = tags.map(&:name)
      tag_names.should include("developer")
      tag_names.should include("designer")

      user_tags = other_user.user_tags
      user_tags.length.should == 2

      # it creates vote for each tag
      user_tags[0].votes.length.should == 1
      user_tags[1].votes.length.should == 1

      unread_emails_for(other_user.email).size.should == parse_email_count(1)
      open_email(other_user.email)
      current_email.should have_subject("Tagged... You're it!")
      current_email.body.should have_content("Great news: User has just tagged you with \"developer\", \"designer\"")
    end
  end

  describe "#vote" do
    let(:tag) { FactoryGirl.build(:tag) }

    before :each do
      sign_in(user)
      controller.stub(:current_user).and_return(user)
    end

    it "can vote for a user tag" do
      user_tag   = FactoryGirl.build(:user_tag, :user => other_user,
                                 :tag => FactoryGirl.create(:tag, name: 'developer'))
      User.stub(:find_by_username!).with(other_user.username).and_return(other_user)
      controller.should_receive(:tag_summary).and_return({})
      other_user.stub_chain(:user_tags, :find).with("1").and_return(user_tag)

      user.should_receive(:add_vote).with(user_tag).and_return(true)

      post :vote, :user_id => other_user.username, :id => "1"
      JSON.parse(response.body)['status'].should == 'ok'

      unread_emails_for(other_user.email).size.should == parse_email_count(1)
      open_email(other_user.email)
      current_email.should have_subject("You received a vote!")
      current_email.should have_content("User vouched for developer")
    end

    it "cannot vote for himself" do
      user_tag = FactoryGirl.build(:user_tag, :user => user)
      User.stub(:find_by_username!).with(other_user.username).and_return(other_user)
      other_user.stub_chain(:user_tags, :find).with("1").and_return(user_tag)

      user.should_receive(:add_vote).with(user_tag).and_return(false)

      post :vote, :user_id => other_user.username, :id => "1"
      JSON.parse(response.body)['status'].should == 'error'

      unread_emails_for(user.email).size.should == parse_email_count(0)
    end
  end

  describe "#unvote" do
    let(:tag) { FactoryGirl.build(:tag) }

    before :each do
      sign_in(user)
      controller.stub(:current_user).and_return(user)
    end

    it "can remove vote from a user tag" do
      user_tag = FactoryGirl.build(:user_tag, tagger: user, tag: tag)
      User.stub(:find_by_username!).with(other_user.username).and_return(other_user)
      controller.should_receive(:tag_summary).and_return({})
      other_user.stub_chain(:user_tags, :find).with("1").and_return(user_tag)
      user.should_receive(:remove_vote).and_return(true)

      post :unvote, :user_id => other_user.username, :id => "1"
      JSON.parse(response.body)['status'].should == 'ok'
    end

    it "cannot remove vote from a user tag is it does not exists" do
      user_tag = FactoryGirl.build(:user_tag, user: user)
      User.stub(:find_by_username!).with(other_user.username).and_return(other_user)
      UserTag.stub(:find).with("1").and_return(user_tag)
      other_user.stub_chain(:user_tags, :find).with("1").and_return(user_tag)
      user.should_receive(:remove_vote).and_return(false)

      post :unvote, :user_id => other_user.username, :id => "1"
      JSON.parse(response.body)['status'].should == 'error'
    end
  end
end

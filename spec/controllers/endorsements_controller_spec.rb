require 'spec_helper'

describe EndorsementsController do
  let(:user) { FactoryGirl.create(:user, full_name: 'User', username: 'user') }
  let(:other_user) { FactoryGirl.create(:user, full_name: "Other User", username: 'other_user') }
  let(:tag) { FactoryGirl.create(:tag, name: 'tag1') }
  let(:user_tag) { FactoryGirl.create(:user_tag, tag: tag, user: user, tagger: other_user) }
  let(:other_user_tag) { FactoryGirl.create(:user_tag, tag: tag, user: other_user, tagger: user) }

  describe "#create" do
    it "requires signed in user" do
      controller.should_not_receive(:create)
      post :create, description: 'something more than 10', user_tag_id: user_tag.id,  endorsed_by_id: other_user.id
    end

    #it "can create endorsement for other user" do
    #  sign_in(user)
    #  controller.stub(:current_user).and_return(user)
    #  # NO IDEA
    #  post :create, description: 'something more than 10', user_tag_id: other_user_tag.id,  endorsed_by_id: user.id
    #end
    #
    #it "can not create endorsement for himself" do
    #  sign_in(user)
    #  controller.stub(:current_user).and_return(user)
    #  # NO IDEA
    #  post :create, description: 'something more than 10', user_tag_id: other_user_tag.id,  endorsed_by_id: user.id
    #end
    #
    #it "can destroy only own endorsements" do
    #  sign_in(user)
    #  controller.stub(:current_user).and_return(user)
    #  # NO IDEA
    #  post :create, description: 'something more than 10', user_tag_id: other_user_tag.id,  endorsed_by_id: user.id
    #end
  end

end

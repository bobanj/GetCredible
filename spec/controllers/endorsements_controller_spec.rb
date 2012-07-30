require 'spec_helper'

describe EndorsementsController do
  let(:user) { FactoryGirl.create(:user, full_name: 'User', username: 'user') }
  let(:tag) { FactoryGirl.create(:tag, name: 'tag1') }
  let(:user_tag) { FactoryGirl.create(:user_tag, tag: tag, user: user, tagger: other_user) }

  describe "#create" do
    it "requires signed in user" do
      controller.should_not_receive(:create)
      post :create, user_id: user.username, endorsement: {}
    end
  end

end

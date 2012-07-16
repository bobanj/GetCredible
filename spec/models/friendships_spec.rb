require 'spec_helper'

describe Friendship do

  describe "Validations" do
    subject { FactoryGirl.create(:friendship) }
    it { should validate_presence_of(:follower_id) }
    it { should validate_presence_of(:followed_id) }
    it { should validate_uniqueness_of(:followed_id).scoped_to(:follower_id) }
  end

  describe "Associations" do
    it { should belong_to(:follower) }
    it { should belong_to(:followed) }
  end


end

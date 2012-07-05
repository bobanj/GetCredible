require 'spec_helper'

describe TwitterContact do
  describe "Attributes" do
    it { should_not allow_mass_assignment_of(:twitter_id) }
    it { should allow_mass_assignment_of(:screen_name) }
    it { should allow_mass_assignment_of(:name) }
    it { should allow_mass_assignment_of(:avatar) }
    it { should allow_mass_assignment_of(:invited) }
  end

  describe "Associations" do
    it { should belong_to(:user) }
  end

  describe "Validations" do
    it { should validate_presence_of(:twitter_id) }
    it { should validate_presence_of(:screen_name) }
    it { should ensure_length_of(:screen_name).is_at_most(255) }
    it { should ensure_length_of(:name).is_at_most(255) }
    it { should ensure_length_of(:avatar).is_at_most(255) }
  end

  describe "#search" do
    it "can find users by screen_name" do
      user1 = FactoryGirl.create(:twitter_contact, screen_name: 'green')
      user2 = FactoryGirl.create(:twitter_contact, screen_name: 'red')
      users = TwitterContact.search(q: 'green')
      users.should include(user1)
      users.should_not include(user2)
    end

    it "can find users by name" do
      user1 = FactoryGirl.create(:twitter_contact, name: 'green')
      user2 = FactoryGirl.create(:twitter_contact, name: 'red')
      users = TwitterContact.search(q: 'green')
      users.should include(user1)
      users.should_not include(user2)
    end

    it "returns all users when query is blank" do
      user1 = FactoryGirl.create(:twitter_contact, name: 'green')
      user2 = FactoryGirl.create(:twitter_contact, name: 'red')
      users = TwitterContact.search(q: '')
      users.should include(user1)
      users.should include(user2)
    end
  end

end

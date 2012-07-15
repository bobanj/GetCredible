require 'spec_helper'

describe Contact do
  describe "Attributes" do
    it { should allow_mass_assignment_of(:uid) }
    it { should allow_mass_assignment_of(:avatar) }
    it { should allow_mass_assignment_of(:url) }
    it { should allow_mass_assignment_of(:screen_name) }
    it { should allow_mass_assignment_of(:name) }
    it { should allow_mass_assignment_of(:invited) }
    it { should allow_mass_assignment_of(:user_id) }
    it { should_not allow_mass_assignment_of(:authentication_id) }
  end

  describe "Associations" do
    it { should belong_to(:authentication) }
    it { should belong_to(:user) }
  end

  describe "Validations" do
    it { should validate_presence_of(:authentication_id) }
    it { should validate_presence_of(:uid) }
    it { should ensure_length_of(:screen_name).is_at_most(255) }
    it { should ensure_length_of(:name).is_at_most(255) }
    it { should ensure_length_of(:avatar).is_at_most(255) }
  end

  describe "#search" do
    it "can find users by screen_name" do
      user1 = FactoryGirl.create(:contact, screen_name: 'green')
      user2 = FactoryGirl.create(:contact, screen_name: 'red')
      users = Contact.search(q: 'green')
      users.should include(user1)
      users.should_not include(user2)
    end

    it "can find users by name" do
      user1 = FactoryGirl.create(:contact, name: 'green')
      user2 = FactoryGirl.create(:contact, name: 'red')
      users = Contact.search(q: 'green')
      users.should include(user1)
      users.should_not include(user2)
    end

    it "returns all users when query is blank" do
      user1 = FactoryGirl.create(:contact, name: 'green')
      user2 = FactoryGirl.create(:contact, name: 'red')
      users = Contact.search(q: '')
      users.should include(user1)
      users.should include(user2)
    end
  end

end

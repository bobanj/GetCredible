require 'spec_helper'

describe AuthenticationContact do
  describe "Attributes" do
    it { should allow_mass_assignment_of(:contact_id) }
    it { should allow_mass_assignment_of(:authentication_id) }
    it { should allow_mass_assignment_of(:invited) }
  end

  describe "Associations" do
    it { should belong_to(:authentication) }
    it { should belong_to(:contact) }
  end

  describe "Validations" do
    it { should validate_presence_of(:authentication_id) }
    it { should validate_presence_of(:contact_id) }
  end

  describe "#search" do
    let(:user) { FactoryGirl.create(:user, full_name: "User") }
    let(:authentication) {
      FactoryGirl.create(:authentication,
                         uid: 't1', provider: 'twitter', user: user)
    }
    let(:contact1) { FactoryGirl.create(:contact, screen_name: 'green', name: 'apple') }
    let(:contact2) { FactoryGirl.create(:contact, screen_name: 'red', name: 'hat') }

    before :each do
      @ac1 = FactoryGirl.create(:authentication_contact,
                         contact: contact1 , authentication: authentication)
      @ac2 = FactoryGirl.create(:authentication_contact,
                         contact: contact2, authentication: authentication)
    end

    it "can find users by screen_name" do
      contacts = AuthenticationContact.search(q: 'Green')
      contacts.should include(@ac1)
      contacts.should_not include(@ac2)
    end

    it "can find users by name" do
      contacts = AuthenticationContact.search(q: 'Apple')
      contacts.should include(@ac1)
      contacts.should_not include(@ac2)
    end

    it "returns all users when query is blank" do
      contacts = AuthenticationContact.search(q: '')
      contacts.should include(@ac1)
      contacts.should include(@ac2)
    end
  end

end

require 'spec_helper'

describe Authentication do
  describe "Attributes" do
    it { should allow_mass_assignment_of(:provider) }
    it { should allow_mass_assignment_of(:uid) }
    it { should allow_mass_assignment_of(:token) }
    it { should allow_mass_assignment_of(:secret) }
    it { should_not allow_mass_assignment_of(:user_id) }
  end

  describe "Associations" do
    it { should belong_to(:user) }
    it { should have_many(:authentication_contacts).dependent(:destroy) }
    it { should have_many(:contacts) }
  end

  describe "Validations" do
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:provider) }
    it { should validate_presence_of(:uid) }
    it { should validate_presence_of(:token) }
  end
end

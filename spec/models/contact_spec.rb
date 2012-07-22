require 'spec_helper'

describe Contact do
  describe "Attributes" do
    it { should allow_mass_assignment_of(:uid) }
    it { should allow_mass_assignment_of(:avatar) }
    it { should allow_mass_assignment_of(:url) }
    it { should allow_mass_assignment_of(:screen_name) }
    it { should allow_mass_assignment_of(:name) }
    it { should allow_mass_assignment_of(:user_id) }
  end

  describe "Associations" do
    it { should belong_to(:user) }
    it { should have_many(:authentication_contacts) }
  end

  describe "Validations" do
    it { should validate_presence_of(:uid) }
    it { should validate_presence_of(:provider) }
    it { should ensure_length_of(:screen_name).is_at_most(255) }
    it { should ensure_length_of(:name).is_at_most(255) }
    it { should ensure_length_of(:avatar).is_at_most(255) }
  end

end

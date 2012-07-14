require 'spec_helper'

describe Contact do
  describe "Attributes" do
    it { should allow_mass_assignment_of(:uid) }
    it { should allow_mass_assignment_of(:avatar) }
    it { should allow_mass_assignment_of(:url) }
    it { should allow_mass_assignment_of(:screen_name) }
    it { should allow_mass_assignment_of(:name) }
    it { should allow_mass_assignment_of(:invited) }
    it { should_not allow_mass_assignment_of(:authentication_id) }
  end

  describe "Associations" do
    it { should belong_to(:authentication) }
  end

  describe "Validations" do
    it { should validate_presence_of(:authentication_id) }
    it { should validate_presence_of(:uid) }
  end

end

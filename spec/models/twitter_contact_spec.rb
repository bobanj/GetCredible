require 'spec_helper'

describe TwitterContact do
  describe "Attributes" do
    it { should allow_mass_assignment_of(:meta_data) }
    it { should allow_mass_assignment_of(:invited) }
  end

  describe "Associations" do
    it { should belong_to(:user) }
  end
end

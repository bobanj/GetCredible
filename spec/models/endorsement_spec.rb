require 'spec_helper'

describe Endorsement do
  let(:endorsement) { FactoryGirl.create(:endorsement) }

  describe "Attributes" do
    it { should allow_mass_assignment_of(:user_tag_id) }
    it { should allow_mass_assignment_of(:endorsed_by_id) }
  end

  describe "Database Columns" do
    it { should have_db_column(:endorsed_by_id).of_type(:integer) }
    it { should have_db_column(:user_tag_id).of_type(:integer) }
    it { should have_db_column(:description).of_type(:text) }
  end

  describe "Associations" do
    it { should belong_to(:user_tag) }
    it { should belong_to(:endorser) }
  end
end

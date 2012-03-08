require 'spec_helper'

describe Tag do

  describe 'Attributes' do
    it { should allow_mass_assignment_of(:name) }
  end

  describe 'Validations' do
    subject { Factory(:tag) }
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end

end

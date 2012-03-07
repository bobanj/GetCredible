require 'spec_helper'

describe Tag do

  describe 'Attributes' do
    it { should allow_mass_assignment_of(:name) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:name) }
  end

end

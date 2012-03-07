require 'spec_helper'

describe UserTag do

  describe 'Attributes' do
    it { should allow_mass_assignment_of(:user_id) }
    it { should allow_mass_assignment_of(:tag_id) }
  end

  describe 'Associations' do
    it { should belong_to(:user) }
    it { should belong_to(:tag) }
  end

  describe 'Validations' do
    it { should validate_presence_of(:user_id) }
    it { should validate_presence_of(:tag_id) }
  end

end

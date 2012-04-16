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

  describe 'Destroy' do
    it "removes user tags and votes after deletion" do
      user  = Factory(:user)
      user2 = Factory(:user)
      UserTag.add_tags(user, user2, ['design'])
      Vote.count.should == 1

      tag = Tag.find_by_name 'design'
      tag.destroy
      Vote.count.should == 0
    end
  end

end

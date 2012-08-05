require 'spec_helper'

describe Link do
  describe "Attributes" do
    it { should allow_mass_assignment_of(:url) }
    it { should allow_mass_assignment_of(:title) }
    it { should allow_mass_assignment_of(:tag_names) }
    it { should_not allow_mass_assignment_of(:user_id) }
  end

  describe "Associations" do
    it { should belong_to(:user) }
    it { should have_and_belong_to_many(:tags) }
    it { should have_many(:activity_items).dependent(:destroy) }
  end

  describe "Validations" do
    it { should validate_presence_of(:url) }
    it { should validate_presence_of(:user_id) }

    it "validates tag names" do
      link = FactoryGirl.build(:link, tag_names: '%, !')
      link.valid?.should be_false
      link.errors[:tag_names].should include("can't be blank")

      link = FactoryGirl.build(:link, tag_names: 'ruby')
      link.valid?.should be_true
    end
  end

  describe "Link saving" do
    it "can save a link" do
      link = FactoryGirl.create(:link, tag_names: 'ruby, rails')

      tags = link.tags.map(&:name)
      tags.should include('ruby')
      tags.should include('rails')
    end
  end
end

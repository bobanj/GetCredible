require 'spec_helper'

describe InvitationMessage do
  describe "Validations" do
    it { should validate_presence_of(:inviter) }
    it { should validate_presence_of(:uid) }

    it "validates provider inclusion" do
      invitation_message = FactoryGirl.build(:invitation_message)
      ['twitter', 'linkedin', 'facebook'].each do |provider|
        invitation_message.provider = provider
        invitation_message.valid?.should be_true
      end

      invitation_message.provider = 'invalid'
      invitation_message.valid?.should be_false
      invitation_message.errors[:provider].should include("is not included in the list")
    end
  end
end

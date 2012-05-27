require 'spec_helper'

describe ActivitiesHelper do
  describe "#user_short" do
    it "adds 's on names that does not end with s" do
      user = FactoryGirl.build(:user, full_name: "Pink")
      helper.user_short(user).should == "Pink's"
    end

    it "adds ' on names ending with s" do
      user = FactoryGirl.build(:user, full_name: "Pinks")
      helper.user_short(user).should == "Pinks'"
    end
  end
end

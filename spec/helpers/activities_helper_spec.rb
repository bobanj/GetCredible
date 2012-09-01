require 'spec_helper'

describe ActivitiesHelper do
  describe "#user_path(user)" do
    it "adds 's on names that does not end with s" do
      helper.apostrophe('Pink').should == "'s"
    end

    it "adds ' on names ending with s" do
      helper.apostrophe('Pinks').should == "'"
    end
  end
end

require 'spec_helper'

describe ActivityItem do

  describe "Associations" do
    it { should belong_to(:user) }
    it { should belong_to(:item) }
  end
end

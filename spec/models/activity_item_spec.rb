require 'spec_helper'

describe ActivityItem do

  describe "Associations" do
    it { should belong_to(:user) }
    it { should belong_to(:item) }
    it { should belong_to(:target) }
  end

  describe "Database Columns" do
    it { should have_db_column(:user_id) }
    it { should have_db_column(:item_id) }
    it { should have_db_column(:item_type) }
    it { should have_db_column(:target_id) }
  end
end

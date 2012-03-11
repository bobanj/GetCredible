require 'spec_helper'

describe ActivityItem do

  describe "Associations" do
    it { should belong_to(:user) }
    it { should belong_to(:item) }
  end

  describe "Database Columns" do
    it { should have_db_column(:user_id) }
    it { should have_db_column(:item_id) }
    it { should have_db_column(:item_type) }
  end
end

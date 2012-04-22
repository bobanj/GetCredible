class AddWeightToUserTag < ActiveRecord::Migration
  def change
    add_column :user_tags, :weight, :float, :default => 1

  end
end

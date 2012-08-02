class AddWeightToVote < ActiveRecord::Migration
  def change
    add_column :votes, :weight, :float, :default => 1
  end
end

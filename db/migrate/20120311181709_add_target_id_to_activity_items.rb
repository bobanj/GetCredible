class AddTargetIdToActivityItems < ActiveRecord::Migration
  def change
    add_column :activity_items, :target_id, :integer
  end
end

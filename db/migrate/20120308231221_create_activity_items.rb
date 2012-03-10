class CreateActivityItems < ActiveRecord::Migration
  def change
    create_table :activity_items do |t|
      t.integer :user_id
      t.integer :item_id
      t.string :item_type
      t.timestamps
    end
  end
end

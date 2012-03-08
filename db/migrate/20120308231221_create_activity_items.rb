class CreateActivityItems < ActiveRecord::Migration
  def change
    create_table :activity_items do |t|
      t.integer :item_id
      t.integer :user_id
      t.string :item_type
      t.string :controller
      t.string :action
      t.string :path

      t.timestamps
    end
  end
end

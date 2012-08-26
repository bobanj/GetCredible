class CreateLinks < ActiveRecord::Migration
  def change
    create_table :links do |t|
      t.integer :user_id
      t.string :url
      t.string :title
      t.text :description
      t.string :thumbnail_url

      t.timestamps
    end

    add_index :links, :user_id
  end
end

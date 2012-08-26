class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.integer :user_id
      t.string :uid
      t.string :screen_name
      t.string :name
      t.string :avatar
      t.string :url
      t.string :provider

      t.timestamps
    end

    add_index :contacts, :user_id
    add_index :contacts, :uid
  end
end

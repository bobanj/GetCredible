class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.integer :authentication_id
      t.string :uid
      t.string :screen_name
      t.string :name
      t.string :avatar
      t.string :url
      t.boolean :invited

      t.timestamps
    end

    add_index :contacts, :authentication_id
    add_index :contacts, :uid
    add_index :contacts, [:authentication_id, :uid]
  end
end

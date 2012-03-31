class CreateAuthentications < ActiveRecord::Migration
  def change
    create_table :authentications do |t|
      t.integer :user_id
      t.string :provider
      t.string :uid
      t.string :secret
      t.string :token

      t.timestamps
    end
    add_index :authentications, :uid
    add_index :authentications, :provider
    add_index :authentications, [:provider, :uid]
  end
end

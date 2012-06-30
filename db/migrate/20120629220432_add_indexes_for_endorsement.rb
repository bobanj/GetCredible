class AddIndexesForEndorsement < ActiveRecord::Migration
  def up
    add_index :endorsements, :endorsed_by_id, :unique => true
    add_index :endorsements, [:endorsed_by_id, :user_tag_id], :unique => true
    add_index :endorsements, [:user_tag_id, :endorsed_by_id], :unique => true
  end

  def down
    remove_index :endorsements, :endorsed_by_id
    remove_index :endorsements, [:endorsed_by_id, :user_tag_id]
    remove_index :endorsements, [:user_tag_id, :endorsed_by_id]
  end
end

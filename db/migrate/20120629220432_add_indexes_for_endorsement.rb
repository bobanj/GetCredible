class AddIndexesForEndorsement < ActiveRecord::Migration
  def up
    add_index :endorsements, :endorsed_by_id
    add_index :endorsements, [:endorsed_by_id, :user_tag_id]
    add_index :endorsements, [:user_tag_id, :endorsed_by_id]
  end

  def down
    remove_index :endorsements, :endorsed_by_id
    remove_index :endorsements, [:endorsed_by_id, :user_tag_id]
    remove_index :endorsements, [:user_tag_id, :endorsed_by_id]
  end
end

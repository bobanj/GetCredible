class CreateEndorsements < ActiveRecord::Migration
  def change
    create_table :endorsements do |t|
      t.integer :user_tag_id
      t.integer :endorsed_by_id
      t.text :description, null: false

      t.timestamps
    end
  end
end

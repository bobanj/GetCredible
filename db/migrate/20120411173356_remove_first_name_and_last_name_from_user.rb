class RemoveFirstNameAndLastNameFromUser < ActiveRecord::Migration
  def up
    change_table :users do |t|
      t.remove_references :invited_by, :polymorphic => true
      t.remove :invitation_limit, :invitation_sent_at, :invitation_accepted_at, :invitation_token
    end
  end

  def down
    add_column :users, :last_name, :string
    add_column :users, :first_name, :string
  end
end

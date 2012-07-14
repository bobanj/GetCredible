class AddSettingsToUser < ActiveRecord::Migration
  def change
    add_column :users, :setting, :text
  end
end

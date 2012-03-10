class AddFieldsToUser < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :job_title
      t.string :city
      t.string :country
      t.string :twitter_handle
      t.string :personal_url
    end
  end
end

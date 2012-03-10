class AddFieldsToUser < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string :company_name
      t.string :company_url
      t.string :first_name
      t.string :last_name
      t.string :job_title
      t.string :street
      t.string :zip
      t.string :city
      t.string :country
      t.string :phone_number
      t.string :twitter_handle
      t.string :personal_url
    end
  end
end

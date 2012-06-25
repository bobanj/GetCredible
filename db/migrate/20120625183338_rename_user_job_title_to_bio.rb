class RenameUserJobTitleToBio < ActiveRecord::Migration
  def change
    rename_column :users, :job_title, :short_bio
  end
end

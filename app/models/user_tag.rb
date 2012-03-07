class UserTag < ActiveRecord::Base

  # Associations
  belongs_to :user
  belongs_to :tag

  # Validations
  validates :user_id, :presence => true
  validates :tag_id, :presence => true
end

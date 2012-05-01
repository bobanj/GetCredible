class ActivityItem < ActiveRecord::Base

  # Associations
  belongs_to :user
  belongs_to :item, :polymorphic => true
  belongs_to :target, :class_name => 'User'

  # Validations
  validates_presence_of :item_id, :item_type, :user_id
end

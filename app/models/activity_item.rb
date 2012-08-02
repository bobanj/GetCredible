class ActivityItem < ActiveRecord::Base

  # Associations
  belongs_to :user
  belongs_to :item, :polymorphic => true
  belongs_to :target, :class_name => 'User'
  has_and_belongs_to_many :tags

  # Validations
  validates_presence_of :item_id, :item_type, :user_id, :tags
end

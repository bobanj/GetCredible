class ActivityItem < ActiveRecord::Base

  # Associations
  belongs_to :user
  belongs_to :item, :polymorphic => true
  belongs_to :target, :class_name => 'User'
  has_and_belongs_to_many :tags

  # Validations
  validates_presence_of :item_id, :item_type, :user_id, :tags

  scope :active, joins(:target).where('users.invitation_token IS NULL')
  scope :ordered, order('activity_items.created_at DESC')
  scope :other_users, where('activity_items.user_id != activity_items.target_id')
end

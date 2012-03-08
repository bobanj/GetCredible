class ActivityItem < ActiveRecord::Base

  # Associations
  belongs_to :user
  belongs_to :item, :polymorphic => true

end

class Endorsement < ActiveRecord::Base
  # Accessible
  attr_accessible :description, :endorsed_by_id, :user_tag_id

  # Associations
  belongs_to :user_tag
  belongs_to :endorser, :class_name => 'User'

end

class Endorsement < ActiveRecord::Base
  # Accessible
  attr_accessible :description, :endorsed_by_id, :user_tag_id, :endorser

  # Associations
  belongs_to :user_tag
  belongs_to :endorser, :class_name => 'User', :foreign_key => :endorsed_by_id

  # Validations
  validates :endorser, presence: true
  validates :user_tag, presence: true, :allow_nil => false
  validates :description, presence: true
  validates :description, :length => {:minimum => 10, :maximum => 300}

end

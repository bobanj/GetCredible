class TwitterContact < ActiveRecord::Base

  # Attributes
  attr_accessible :invited, :meta_data

  # Attributes
  belongs_to :user

  # Store
  store :meta_data, accessors: [ :screen_name, :name, :avatar ]

  # Scopes
  scope :ordered, order('id ASC')

end

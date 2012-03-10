class Tag < ActiveRecord::Base

  # Attributes
  attr_accessible :name

  # Validations
  validates :name, :presence => true, :uniqueness => true

  # TODO: dependent destroy user_tags
  # Associations

end

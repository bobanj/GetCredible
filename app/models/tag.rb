class Tag < ActiveRecord::Base

  # Attributes
  attr_accessible :name

  # Validations
  validates :name, :presence => true

end

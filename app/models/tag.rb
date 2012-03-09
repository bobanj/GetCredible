class Tag < ActiveRecord::Base
  # Additions
  acts_as_voteable

  # Attributes
  attr_accessible :name

  # Validations
  validates :name, :presence => true, :uniqueness => true

end

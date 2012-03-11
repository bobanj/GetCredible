class Tag < ActiveRecord::Base

  # Attributes
  attr_accessible :name

  # Validations
  validates :name, :presence => true, :uniqueness => true

  # Associations
  has_many :user_tags, :dependent => :destroy
end

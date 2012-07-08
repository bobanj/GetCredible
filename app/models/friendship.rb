class Friendship < ActiveRecord::Base
  attr_accessible :followed_id, :follower_id

  # Validations
  validates :follower_id, presence: true
  validates :followed_id, presence: true
  validates_uniqueness_of :followed_id, :scope => :follower_id

  # Associations
  belongs_to :follower, class_name: "User"
  belongs_to :followed, class_name: "User"
end

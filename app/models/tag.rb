class Tag < ActiveRecord::Base

  # Attributes
  attr_accessible :name

  # Validations
  validates :name, :presence => true, :uniqueness => true

  # Associations
  has_many :user_tags, :dependent => :destroy
  has_many :votes, :through => :user_tags
  has_many :voters, :through => :votes, :uniq => true
  has_many :voted_users, :through => :votes
  has_many :voted_ranking, :through => :votes, :source => :voted_users,
    :select => "users.id, COUNT(*) AS votes_count", :group => "users.id",
    :order => "votes_count DESC"

  def self.voted_ranking
    voted_users.select("users.id, COUNT(*) AS votes_count").group("users.id").
    order("votes_count DESC")
  end
end

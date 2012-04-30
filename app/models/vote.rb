class Vote < ActiveRecord::Base
  # Scopes
  scope :for_voter, lambda { |*args| where(["voter_id = ?", args.first.id]) }
  scope :for_voteable, lambda { |*args| where(["voteable_id = ?", args.first.id]) }
  scope :recent, lambda { |*args| where(["created_at > ?", (args.first || 2.weeks.ago)]) }
  scope :descending, order("created_at DESC")

  # Associations
  belongs_to :user_tag, :foreign_key => "voteable_id"
  belongs_to :voteable, :class_name => 'UserTag'
  belongs_to :voter, :class_name => 'User'
  has_many :activity_items, :as => :item, :dependent => :destroy
  has_many :voted_users, :through => :user_tag, :source => :user

  # Validations
  validates_presence_of :voteable_id, :voter_id, :vote

  # Accessible
  attr_accessible :vote, :voter, :voteable, :user

  # Callbacks
  # before_create :set_weight # NOTE: disabled, see: lib/tasks/calculate_rank.rake
  after_create :update_voteable_counters
  after_destroy :update_voteable_counters

  # Validations
  # Comment out the line below to allow multiple votes per user.
  validates_uniqueness_of :voteable_id, :scope => :voter_id

  def self.for_tag(tag)
    joins("INNER JOIN user_tags ON user_tags.id = votes.voteable_id").
    joins("INNER JOIN tags ON user_tags.tag_id = tags.id").
    where("tags.id = ?", tag.id)
  end

  private

  def update_voteable_counters
    voteable.update_counters
    voter_user_tag = voter.user_tags.where(:tag_id => voteable.tag_id).first
    voter_user_tag.update_counters if voter_user_tag
  end

end

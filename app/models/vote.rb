class Vote < ActiveRecord::Base
  # Scopes
  scope :for_voter, lambda { |*args| where(["voter_id = ? AND voter_type = ?", args.first.id, args.first.class.base_class.name]) }
  scope :for_voteable, lambda { |*args| where(["voteable_id = ? AND voteable_type = ?", args.first.id, args.first.class.base_class.name]) }
  scope :recent, lambda { |*args| where(["created_at > ?", (args.first || 2.weeks.ago)]) }
  scope :descending, order("created_at DESC")

  # Activities
  belongs_to :user_tag, :foreign_key => "voteable_id"
  belongs_to :voteable, :polymorphic => true
  belongs_to :voter, :polymorphic => true
  has_many :activity_items, :as => :item, :dependent => :destroy

  attr_accessible :vote, :voter, :voteable, :user

  # Callbacks
  before_create :set_weight

  # Validations
  # Comment out the line below to allow multiple votes per user.
  validates_uniqueness_of :voteable_id, :scope => [:voteable_type, :voter_type, :voter_id]

  private

  def set_weight
    # Returns Array of arrays [user_id, weight]
    tbl = Vote.select("user_tags.user_id").
        joins(:user_tag).
        where("user_tags.user_id IN (SELECT votes.voter_id FROM votes GROUP BY votes.voter_id) AND user_tags.tag_id = ?", voteable.tag.id).
        group("user_tags.user_id").sum(:weight)
    tbl = tbl.to_a
    weights = tbl.map { |t| t[1] }
    standardized = Vote.standardize_random_variable(weights)
    if weights == standardized
      self.weight = 1
      return
    end
    tbl_size = tbl.size
    if tbl_size > 30
      confidence = Statistics2.pnormaldist(0.005)
      lower = -confidence * (1/Math.sqrt(tbl_size))
      upper = confidence * (1/Math.sqrt(tbl_size))
    else
      confidence = Statistics2.ptdist(29,0.005)
      lower = -confidence * (1/Math.sqrt(tbl_size))
      upper = confidence * (1/Math.sqrt(tbl_size))
    end
      find_voter = tbl.find{|t| t[0] == self.voter_id}
    if find_voter
      voter_index = tbl.index(find_voter)
      voter_votes = find_voter[1]
      voter_votes_standardized = standardized[voter_index]
      total_sum_voters = weights.sum
      total_sum_user_tag = Vote.where("voteable_id = ?", self.voteable_id).sum(:weight)
      max_voter_votes = weights.max
      if voter_votes_standardized.between?(lower, upper)
        self.weight = (total_sum_user_tag / total_sum_voters) * (total_sum_voters / max_voter_votes ) + 1
      elsif voter_votes_standardized < lower
        self.weight = (voter_votes / total_sum_voters) * (total_sum_user_tag / total_sum_voters) * (total_sum_voters / max_voter_votes ) + 1
      elsif voter_votes_standardized > upper
        self.weight = (voter_votes / total_sum_voters) * (total_sum_user_tag / total_sum_voters) * (total_sum_voters / max_voter_votes ) + 2
      end
    else
      self.weight = 1
    end
  end

  def self.standardize_random_variable(arr)
    return arr if arr.empty?
    mean = arr.mean
    variance = arr.variance
    return arr if variance == 0
    arr.map { |a| (a-mean)/variance }
  end

end

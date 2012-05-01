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

  # Callbacks
  after_save :load_into_soulmate
  after_destroy :unload_from_soulmate

  # Class Methods
  class << self
    def voted_ranking
      voted_users.select("users.id, COUNT(*) AS votes_count").group("users.id").
          order("votes_count DESC")
    end

    def search(term)
      return [] if term.blank?
      matches = Soulmate::Matcher.new('tag').matches_for_term(term)
      matches.collect { |match| {"id" => match["id"], "term" => match["term"]} }
    end
  end

  private

  def load_into_soulmate
    loader = Soulmate::Loader.new("tag")
    loader.add("term" => name, "id" => id)
  end

  def unload_from_soulmate
    loader = Soulmate::Loader.new("tag")
    loader.remove("term" => name, "id" => id)
  end
end

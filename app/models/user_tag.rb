class UserTag < ActiveRecord::Base

  # Associations
  belongs_to :user
  belongs_to :tag, :counter_cache => true
  belongs_to :tagger, :class_name => 'User'
  has_many :votes, :foreign_key => :voteable_id, :dependent => :destroy
  has_many :activity_items, :as => :item, :dependent => :destroy
  has_many :voters, :through => :votes
  has_many :last_voters, :through => :votes, :source => :voter, :order => 'id DESC', :limit => 5

  # Validations
  validates :user_id, :presence => true
  validates :tagger_id, :presence => true
  validates :tag_id, :presence => true, :uniqueness => {:scope => :user_id}

  # Redis
  include Redis::Objects
  value :outgoing
  value :incoming

  # Callbacks
  after_destroy :remove_from_redis

  def update_counters
    self.incoming.value = calculate_incoming
    self.outgoing.value = calculate_outgoing
  end

  def self.add_tags(tagger, user, tag_names)
    user_tags = user.user_tags
    new_tags  = []

    tag_names.each do |tag_name|
      tag = Tag.find_or_create_by_name(tag_name)
      user_tag = user_tags.detect{ |user_tag| user_tag.tag_id == tag.id }

      if user_tag
        # just add vote if tag already exists
        tagger.add_vote(user_tag)
      else
        new_tags << tag.name
        user_tag = user.user_tags.new
        user_tag.tag = tag
        user_tag.tagger = tagger
        user_tag.save
        tagger.activity_items.create(:item => user_tag, :target => user)

        # automatically add vote on tag creation
        tagger.add_vote(user_tag, false)
      end
    end

    # email user with the new tags
    UserMailer.tag_email(tagger, user, new_tags).deliver if new_tags.present?
  end

  private
  def calculate_outgoing
    self.user.votes.joins({:user_tag => :tag}).where("tags.id = ?", tag_id).count
  end

  def calculate_incoming
    self.votes.count
  end

  def remove_from_redis
    Redis::SortedSet.new("tag:#{tag_id}:scores").delete(id)
    Redis::Value.new("user_tag:#{id}:incoming").delete
    Redis::Value.new("user_tag:#{id}:outgoing").delete
  end

end

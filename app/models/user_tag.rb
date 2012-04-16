class UserTag < ActiveRecord::Base

  # Additions
  acts_as_voteable

  # Associations
  belongs_to :user
  belongs_to :tag
  belongs_to :tagger, :class_name => 'User'
  has_many :activity_items, :as => :item, :dependent => :destroy

  # Validations
  validates :user_id, :presence => true
  validates :tagger_id, :presence => true
  validates :tag_id, :presence => true, :uniqueness => {:scope => :user_id}

  def calculate_votes
    sum_weight = votes.map(&:weight).sum
    (sum_weight + 0.5).floor
  end

  def self.add_tags(user, tagger, tag_names)
    user_tags = user.user_tags
    tag_names.each do |tag_name|
      tag = Tag.find_or_create_by_name(tag_name)
      user_tag = user_tags.detect{ |user_tag| user_tag.tag_id == tag.id }

      if user_tag
        # just add vote if tag already exists
        tagger.add_vote(user_tag)
      else
        user_tag = user.user_tags.new
        user_tag.tag = tag
        user_tag.tagger = tagger
        user_tag.save
        tagger.activity_items.create(:item => user_tag, :target => user)

        # automatically add vote on tag creation
        tagger.add_vote(user_tag, false)
      end
    end
  end
end

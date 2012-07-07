class Endorsement < ActiveRecord::Base
  # Accessible
  # we need both tag and user to create a user_tag so it can be endorsed
  # tag_name is the name of the new tag if there isn't one
  # user_id is the user who is endorsed
  attr_accessor :tag_name, :user_id
  attr_accessible :description, :endorsed_by_id, :user_tag_id, :endorser, :tag_name, :user_id

  # Associations
  belongs_to :user_tag
  belongs_to :endorser, :class_name => 'User', :foreign_key => :endorsed_by_id
  has_one :tag, :through => :user_tag
  has_one :user, :through => :user_tag
  has_many :activity_items, :as => :item, :dependent => :destroy

  # Validations
  validates :user_id, presence: true, if: lambda { |e| e.user_tag_id.blank? }
  validates :tag_name, presence: true, if: lambda { |e| e.user_tag_id.blank? }
  validates :endorser, presence: true, :allow_nil => false
  validates :user_tag, presence: true, :allow_nil => false,if: lambda { |e| e.user_id.blank? || e.tag_name.blank? }
  validates :description, presence: true
  validates :description, :length => {:minimum => 10, :maximum => 300}
  validate :user_can_not_endorse_himself, unless: lambda { |e| e.user_tag_id.blank? }

  # Callbacks
  after_validation :set_user_tag, if: lambda { |e| e.user_tag_id.blank? && !e.errors.present? }
  before_save :create_vote

  #Scopes
  scope :latest, order("created_at desc")

  private
  def user_can_not_endorse_himself
    if user_tag.try(:user_id) == endorsed_by_id
      errors.add(:description, "You can't endorse yourself")
    end
  end

  def create_vote
    endorser.add_vote(user_tag, false)
  end

  def set_user_tag
    user = User.find_by_id user_id
    self.tag_name = TagCleaner.clean(tag_name).first
    tag = Tag.find_or_create_by_name tag_name
    self.user_tag = user.user_tags.detect { |user_tag| user_tag.tag_id == tag.id }
    unless user_tag
      self.user_tag = user.user_tags.create(tag: tag, tagger: endorser)
    end
  end
end

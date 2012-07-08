class Endorsement < ActiveRecord::Base
  # Accessible
  # we need both tag and user to create a user_tag so it can be endorsed
  # tag_name is the name of the new tag if there isn't one
  # user_id is the user who is endorsed
  attr_accessible :description, :endorsed_by_id, :user_tag_id, :endorser

  # Associations
  belongs_to :user_tag
  belongs_to :endorser, :class_name => 'User', :foreign_key => :endorsed_by_id
  has_one :tag, :through => :user_tag
  has_one :user, :through => :user_tag
  has_many :activity_items, :as => :item, :dependent => :destroy

  # Validations
  validates :endorser, presence: true, :allow_nil => false
  validates :user_tag_id, presence: true, :allow_nil => false
  validates :description, presence: true
  validates :description, :length => {:minimum => 10, :maximum => 300}
  validate :user_can_not_endorse_himself

  # Callbacks
  before_save :create_vote

  #Scopes
  scope :latest, order("created_at desc")

  private
  def user_can_not_endorse_himself
    if user_tag && user_tag.user_id == endorsed_by_id
      errors.add(:description, "You can't endorse yourself")
    end
  end

  def create_vote
    endorser.add_vote(user_tag, false)
  end

end

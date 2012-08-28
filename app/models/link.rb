class Link < ActiveRecord::Base

  # Attributes
  attr_accessible :url, :title, :description, :thumbnail_url, :tag_names
  attr_accessor :tag_names

  # Associatoins
  belongs_to :user
  has_many :activity_items, :as => :item, :dependent => :destroy
  has_and_belongs_to_many :tags

  # Validations
  validates :url, presence: true
  validates :user_id, presence: true
  validate :tag_names_presence

  # Callbacks
  before_save :set_tags

  # Scopes
  scope :ordered, order('created_at DESC')

  private
  def tag_names_presence
    cleaned_tag_names = TagCleaner.clean(tag_names)
    errors[:tag_names] << "can't be blank" if cleaned_tag_names.blank?
  end

  def set_tags
    cleaned_tag_names = TagCleaner.clean(tag_names)
    cleaned_tag_names.each do |tag_name|
      self.tags << Tag.find_or_create_by_name(tag_name)
    end
  end
end

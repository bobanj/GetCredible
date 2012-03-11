class UserTag < ActiveRecord::Base

  # Additions
  acts_as_voteable

  # Associations
  belongs_to :user
  belongs_to :tag
  belongs_to :tagger, :class_name => 'User'
  has_many :activity_items, :as => :item

  # Validations
  validates :user_id, :presence => true
  validates :tag_id, :presence => true, :uniqueness => {:scope => :user_id}

  def self.add_tags(user, tagger, tag_names)
    tag_names.to_s.split(',').each do |tag_name|
      tag = Tag.find_or_create_by_name(tag_name.strip)
      unless user.tags.where(:name => tag.name).any?
        user_tag = user.user_tags.new
        user_tag.tag = tag
        user_tag.tagger = tagger
        user_tag.save
        tagger.activity_items.create(:item => user_tag, :target => user)
      end
    end
  end
end

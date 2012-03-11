class UserTag < ActiveRecord::Base

  # Additions
  acts_as_voteable

  # Associations
  belongs_to :user
  belongs_to :tag
  belongs_to :tagger, :class_name => 'User'

  # Validations
  validates :user_id, :presence => true
  validates :tag_id, :presence => true, :uniqueness => {:scope => :user_id}

  def self.add_tags(user, tagger, tag_names)
    tag_names.to_s.split(',').each do |tag_name|
      tag = Tag.find_or_initialize_by_name(tag_name.strip)
      if tag.new_record? && tag.valid?
        tag.save
        user.activity_items.create(:item => tag)
      end
      unless user.tags.include?(tag)
        user_tag = user.user_tags.new
        user_tag.tag = tag
        user_tag.tagger = tagger
        user_tag.save
      end
    end
  end
end

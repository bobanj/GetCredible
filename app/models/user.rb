class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Additions
  acts_as_voter
  mount_uploader :avatar, AvatarUploader

  # Attributes
  attr_accessible :email, :password, :password_confirmation, :remember_me,
    :first_name, :last_name, :job_title, :city, :country, :twitter_handle,
    :personal_url, :avatar, :avatar_cache

  # Associations
  has_many :user_tags, dependent: :destroy
  has_many :tags, through: :user_tags
  has_many :activity_items, dependent: :destroy

  # Validations
  validates :first_name, :last_name, :job_title, :presence => true, :format => {:with => /^[\w\s-]*$/}

  def full_name
    "#{first_name} #{last_name}"
  end

  def add_tags(tag_names)
    tag_names.to_s.split(',').each do |tag_name|
      tag = Tag.find_or_initialize_by_name(tag_name.strip)
      if tag.new_record? && tag.valid?
        tag.save
        self.activity_items.create(:item_id => tag.id, :item_type => tag.class.name)
      end
      self.tags << tag unless tags.include?(tag)
    end
  end

  def tags_summary(user=nil)
    user_tags.includes([:tag, :votes]).map do |user_tag|
      {
        id: user_tag.id,
        name: user_tag.tag.name,
        voted: user && user.voted_for?(user_tag),
        votes: user_tag.votes.length
      }
    end
  end
end

class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Additions
  acts_as_voter
  mount_uploader :avatar, AvatarUploader

  # Attributes
  attr_accessible :email, :password, :password_confirmation, :remember_me
  attr_accessible :first_name, :last_name, :job_title, :street, :zip, :city, :company_name, :company_url, :country, :phone_number, :twitter_handle, :personal_url, :avatar, :avatar_cache

  # Associations
  has_many :user_tags, dependent: :destroy
  has_many :tags, through: :user_tags



  def add_tags(tag_names)
    tag_names.to_s.split(',').each do |tag_name|
      tag = Tag.find_or_create_by_name(tag_name.strip)
      self.tags << tag unless tags.include?(tag)
    end
  end

  def tags_summary(user)
    tags = []

    user_tags.includes([:tag, :votes]).each do |user_tag|
      tags << {
        id: user_tag.id,
        name: user_tag.tag.name,
        voted: user_tag.votes.any?{|vote| vote.voter_id == user.id},
        votes: user_tag.votes.length
      }
    end

    tags
  end
end

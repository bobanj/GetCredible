class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Additions
  acts_as_voter

  # Attributes
  attr_accessible :email, :password, :password_confirmation, :remember_me

  # Associations
  has_many :user_tags, dependent: :destroy
  has_many :tags, through: :user_tags



  def tag(tag_names)
    tag_names.to_s.split(',').each do |tag_name|
      tag = Tag.find_or_create_by_name(tag_name.strip)
      self.tags << tag unless tags.include?(tag)
    end
  end
end

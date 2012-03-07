class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Attributes
  attr_accessible :email, :password, :password_confirmation, :remember_me

  # Associations
  has_many :user_tags, :dependent => :destroy
  has_many :tags, :through => :user_tags
end

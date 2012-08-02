class User < ActiveRecord::Base

  include ApplicationHelper
  include ActionView::Helpers::AssetTagHelper

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  # Additions
  mount_uploader :avatar, AvatarUploader

  # Attributes
  attr_accessible :email, :password, :password_confirmation, :remember_me,
    :username, :full_name, :short_bio, :location, :twitter_handle,
    :personal_url, :avatar, :avatar_cache, :tag_names, :remote_avatar_url

  attr_accessor :tag_names

  # Associations
  has_many :user_tags, dependent: :destroy
  has_many :tags, through: :user_tags, :order => "name asc"
  has_many :activity_items, order: 'created_at desc', dependent: :destroy
  has_many :incoming_activities, :foreign_key => :target_id,
                                 :class_name => 'ActivityItem',
                                 :order => 'created_at DESC'
  has_many :votes, :foreign_key => :voter_id, :dependent => :destroy
  has_many :voted_users, :through => :votes, :uniq => true # Users who you voted for
  has_many :voters, :through => :user_tags, :uniq => true # Users who voted for you
  has_many :incoming_endorsements, :through => :user_tags, :source => :endorsements
  has_many :outgoing_endorsements, :class_name => 'Endorsement', :foreign_key => :endorsed_by_id, :dependent => :destroy

  # Friendships
  has_many :friendships, :foreign_key => :follower_id, :dependent => :destroy
  has_many :reverse_friendships, :foreign_key => :followed_id,
              :class_name => 'Friendship', :dependent => :destroy
  has_many :followings, :through => :friendships, :source => :followed
  has_many :followers, :through => :reverse_friendships, :source => :follower

  has_many :authentications, dependent: :destroy
  has_one :twitter_authentication, class_name: 'Authentication',
          conditions: "authentications.provider = 'twitter'"
  has_many :twitter_authentication_contacts, through: :twitter_authentication, source: :authentication_contacts
  has_many :twitter_contacts, through: :twitter_authentication_contacts, source: :contact

  has_one :linkedin_authentication, class_name: 'Authentication',
          conditions: "authentications.provider = 'linkedin'"
  has_many :linkedin_authentication_contacts, through: :linkedin_authentication, source: :authentication_contacts
  has_many :linkedin_contacts, through: :linkedin_authentication_contacts, source: :contact

  has_one :facebook_authentication, class_name: 'Authentication',
          conditions: "authentications.provider = 'facebook'"
  has_many :facebook_authentication_contacts, through: :facebook_authentication, source: :authentication_contacts
  has_many :facebook_contacts, through: :facebook_authentication_contacts, source: :contact

  has_many :authentication_contacts, through: :authentications
  has_many :contacts, through: :authentication_contacts
  has_one :contact

  # Validations
  validates :username, :presence => true,
               :format => { with: /^\w+$/,
                            message: "only use letters, numbers and '_'" },
               :length => { minimum: 3 },
               :uniqueness => true,
               :exclusion => { :in => %w(admin superuser test) }
  validates :personal_url, :url_format => true, :allow_blank => true
  validate :username_is_not_a_route
  validates :short_bio, :length => {:maximum => 200}

  # Callbacks
  before_validation :add_protocol_to_personal_url
  before_validation :clean_twitter_username
  after_invitation_accepted :email_followers

  # Scopes
  scope :none, where("1 = 0")
  scope :active, where('users.invitation_token IS NULL')
  scope :inactive, where('usrs.invitation_token IS NOT NULL')
  scope :order_by_invitation_time, order("users.invitation_sent_at desc")
  scope :order_by_name, order('users.full_name ASC, users.username ASC')

  # Store
  store :settings, accessors: [:twitter_state, :linkedin_state, :facebook_state]

  def profile_complete_percent
    empty_count = 0
    empty_count += 1 if job_title.blank?
    empty_count += 1 if location.blank?
    empty_count += 1 if twitter_handle.blank?
    empty_count += 1 if full_name.blank?
    empty_count += 1 if personal_url.blank?
    empty_count += 1 unless user_tags.any?
    empty_count += 1 unless avatar.present?
    percentage = ((9 - empty_count) * 100) / 9
    [0,percentage,100].sort[1]
  end

  def short_name
    name ? name.to_s.split(' ').first : username
  end

  def name
    read_attribute(:full_name).presence || username
  end

  def friends
    followings & followers
  end

  def active?
    invitation_token.blank?
  end

  def pending
    User.invited_by(self).inactive
  end

  def top_tags(limit)
    user_tags.joins(:votes).
      select('user_tags.id, user_tags.tag_id, COUNT(*) AS total_votes').
      group("votes.voteable_id, user_tags.id, user_tags.tag_id").
      limit(limit).order('total_votes DESC').
      includes(:tag).
      map { |user_tag| user_tag.tag }
  end

  def interacted_by(other_user)
    user_tags.joins(:votes).where('votes.voter_id = ?', other_user.id).exists?
  end

  def add_tags(user, tag_names, options = {})
    UserTag.add_tags(self, user, tag_names, options)
  end

  def following?(user)
    followings.exists?(user)
  end

  def follow(user)
    followings << user unless following?(user)
  end

  def unfollow(user)
    followings.delete(user) if following?(user)
  end

  def add_vote(user_tag, log_vote_activity = true)
    if self != user_tag.user
      vote = vote_exclusively_for(user_tag)
      follow(user_tag.user)
      # Vote.create!(:vote => direction, :voteable => voteable, :voter => self)
      if log_vote_activity
        ActivityItem.create(user: self, item: vote,
                            target: user_tag.user, tags: [user_tag.tag])
      end
    else
      vote = false
    end
    vote
  end

  def voted_for?(user_tag)
    Vote.exists?(:voter_id => self.id, :voteable_id => user_tag.id)
  end

  def remove_vote(user_tag)
    if user_tag.tagger == self && user_tag.votes.length <= 1
      user_tag.destroy
    else
      vote = user_tag.votes.for_voter(self).first
      vote ? vote.destroy : false
    end
  end

  def incoming_activities_for_others
    incoming_activities.different_user_target
  end

  def outgoing_activities
    activity_items.active.ordered
  end

  def outgoing_activities_for_others
    activity_items.active.different_user_target.ordered
  end

  def all_activities
    users_ids = (friends + [self]).map(&:id)
    ActivityItem.active.ordered.where(['user_id IN (?)', users_ids])
  end

  def vote_exclusively_for(voteable)
    Vote.where(:voter_id => self.id, :voteable_id => voteable.id).map(&:destroy)
    Vote.create!(:vote => true, :voteable => voteable, :voter => self)
  end

  def update_twitter_oauth(token, secret)
    self.twitter_token  = token
    self.twitter_secret = secret
    self.save(validate: false)
  end

  def disconnect_from_provider(provider)
    authentication = authentications.find_by_provider(provider)
    if authentication && authentication.user.send(:"#{provider}_state") == 'finished'
      authentication.destroy
      self.update_attribute(:"#{provider}_state", nil)
      return true
    else
      return false
    end
  end

  def to_param
    username
  end

  # Changes error message for attribute if error already exists
  def change_error_message(field, message)
    if self.errors[field].include?('is already registered')
      self.errors[field].clear
      self.errors[field]= message
    end
  end

  def endorse(user_tag, description)
    unless user_tag.user_id == self.id
      user_tag.endorsements.create endorser: self, description: description
    end
  end

  # Class methods

  def self.search(params)
    scope = scoped
    if params[:q].to_s.length >= 2
      scope = scope.active.search_by_name_or_tag(params[:q])
    else
      scope = scope.none
    end
    scope = scope.paginate(:per_page => 10, :page => params[:page])

    scope
  end

  def self.search_by_name_or_tag(q)
    includes(user_tags: :tag).
      where("UPPER(users.full_name) LIKE UPPER(:q) OR
             UPPER(users.username) LIKE UPPER(:q) OR
             UPPER(tags.name) LIKE UPPER(:q)", {:q => "%#{q}%"})
  end

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:email)
      where(conditions).where(["lower(username) = :value OR lower(email) = :value",
                               { :value => login.downcase }]).first
    else
      where(conditions).first
    end
  end

  def self.invited_by(user)
    where(:invited_by_id => user.id).inactive.order_by_invitation_time
  end

  private
  def email_required?
    authentications.blank?
  end

  def add_protocol_to_personal_url
    personal_url.to_s.strip!
    if personal_url.present? && personal_url !~ /http/
      self.personal_url = 'http://' + personal_url
    end
  end

  def clean_twitter_username
    twitter_handle.to_s.strip!
    if twitter_handle.present? && twitter_handle[0] == '@'
      self.twitter_handle = twitter_handle[1..-1]
    end
  end

  def username_is_not_a_route
    path = Rails.application.routes.
        recognize_path("#{username}", :method => :get) rescue nil

    if !(path && path[:controller] == 'users' &&
         path[:action] == 'show' && path[:id] == username)
      errors.add(:username, "is not available")
    end
  end

  def email_followers
    followers.each do |follower|
      UserMailer.invitation_accepted_email(follower, self).deliver
    end
  end
end

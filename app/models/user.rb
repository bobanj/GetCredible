class User < ActiveRecord::Base

  include ApplicationHelper
  include ActionView::Helpers::AssetTagHelper

  # Include default devise modules. Others available are:
  # :token_authenticatable, :encryptable, :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable #, :omniauthable

  # Additions
  mount_uploader :avatar, AvatarUploader

  # Attributes
  attr_accessible :email, :password, :password_confirmation, :remember_me,
    :username, :full_name, :job_title, :location, :twitter_handle,
    :personal_url, :avatar, :avatar_cache

  # Associations
  has_many :authentications, dependent: :destroy
  has_many :user_tags, dependent: :destroy
  has_many :tags, through: :user_tags, :order => "name asc"
  has_many :activity_items, order: 'created_at desc', dependent: :destroy
  has_many :incoming_activities, :foreign_key => :target_id,
                                 :class_name => 'ActivityItem',
                                 :order => 'created_at DESC'
  has_many :votes, :foreign_key => :voter_id, :dependent => :destroy
  has_many :voted_users, :through => :votes, :uniq => true
  has_many :voters, :through => :user_tags, :uniq => true

  # Validations
  validates :username, :presence => true,
               :format => { with: /^\w+$/,
                            message: "only use letters, numbers and '_'" },
               :length => { minimum: 3 },
               :uniqueness => true
  validates :personal_url, :url_format => true, :allow_blank => true

  # Callbacks
  before_validation :add_protocol_to_personal_url

  # Scopes
  scope :none, where("1 = 0")

  def short_name
    full_name.to_s.split(' ').first
  end

  def full_name
    read_attribute(:full_name).presence || username
  end

  def friends
    voted_users & voters
  end

  def get_rank(rates, user)
    rank = 1

    rates.each_with_index do |user_tag, index|
      if user_tag.user_id = user.id
        rank = index + 1
        break
      end
    end

    return rank
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

  def add_tags(user, tag_names)
    UserTag.add_tags(self, user, tag_names)
  end

  def add_vote(user_tag, log_vote_activity = true)
    if self != user_tag.user
      vote = vote_exclusively_for(user_tag)
      # Vote.create!(:vote => direction, :voteable => voteable, :voter => self)
      if log_vote_activity
        activity_items.create(item: vote, target: user_tag.user)
      end
    else
      vote = false
    end
    vote
  end

  def remove_vote(user_tag)
    if user_tag.tagger == self && user_tag.votes.length <= 1
      user_tag.destroy
    else
      vote = user_tag.votes.for_voter(self).first
      vote ? vote.destroy : false
    end
  end
  def apply_omniauth(omniauth)
    unless omniauth['credentials'].blank?
      authentications.build(:provider => omniauth['provider'],
                            :uuid => omniauth['uid'],
                            :token => omniauth['credentials']['token'],
                            :secret => omniauth['credentials']['secret'])

    end
  end

  def outgoing_activities
    activity_items.order('created_at DESC')
  end

  def all_activities(params = {})
    ActivityItem.paginate_by_sql(["SELECT t.* FROM
                        (
                          SELECT activity_items.* FROM activity_items
                          WHERE activity_items.user_id = :id
                          UNION
                          SELECT activity_items.* FROM activity_items
                          WHERE activity_items.user_id IN (:user_ids)
                          UNION
                          SELECT activity_items.*
                          FROM activity_items
                          WHERE activity_items.target_id = :id
                        ) AS t
                        ORDER BY created_at DESC", id: id, user_ids: friends.map(&:id)],
                        :page => params[:page], :per_page => params[:per_page])
  end

  def vote_exclusively_for(voteable)
    Vote.where(:voter_id => self.id, :voteable_id => voteable.id).map(&:destroy)
    Vote.create!(:vote => true, :voteable => voteable, :voter => self)
  end

  def to_param
    username
  end

  # Class methods

  def self.search(params)
    scope = scoped
    if params[:q].present?
      scope = scope.search_by_name_or_tag(params[:q])
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

  private
    def email_required?
      authentications.blank?
    end

    def add_protocol_to_personal_url
      if personal_url.present? && personal_url !~ /http/
        self.personal_url = 'http://' + personal_url
      end
    end
end

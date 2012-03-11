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
  has_many :incoming_activities, :foreign_key => :target_id,
                                 :class_name => 'ActivityItem',
                                 :order => 'created_at DESC'

  # Validations
  validates :first_name, :last_name, :job_title, :presence => true, :format => {:with => /^[\w\s-]*$/}

  def full_name
    "#{first_name} #{last_name}"
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

  def top_tags(limit)
    tags = user_tags.joins(:votes).
      select('user_tags.id, user_tags.tag_id, COUNT(*) AS total_votes').
      group("votes.voteable_id, user_tags.id, user_tags.tag_id").
      limit(limit).order('total_votes DESC').
      includes(:tag).map do |user_tag|
        {
          name: user_tag.tag.name,
          votes: user_tag.total_votes
        }
      end
  end

  def interacted_by(other_user)
    user_tags.joins(:votes).where('votes.voter_id = ?', other_user.id).exists?
  end

  def add_vote(user_tag)
    if self != user_tag.user
      vote = vote_exclusively_for(user_tag)
      activity_items.create(item: vote, target: user_tag.user)
    else
      false
    end
  end

  def remove_vote(user_tag)
    vote = user_tag.votes.for_voter(self).first
    vote ? vote.destroy : false
  end

  def self.search(params)
    scope = scoped
    scope = scope.search_by_name_or_tag(params[:q]) if params[:q].present?
    scope = scope.paginate(:per_page => 10, :page => params[:page])

    scope
  end

  def self.search_by_name_or_tag(q)
    includes(user_tags: :tag).
    where("UPPER(users.first_name || ' ' || users.last_name) LIKE UPPER(:q) OR
           UPPER(tags.name) LIKE UPPER(:q)", {:q => "%#{q}%"})
  end

  def outgoing_activities
    activity_items.order('created_at DESC')
  end

  def all_activities
    ActivityItem.paginate_by_sql("SELECT t.* FROM
                                (SELECT activity_items.* FROM activity_items
                                  WHERE activity_items.user_id = #{id}
                                  UNION
                                  SELECT activity_items.*
                                  FROM activity_items
                                  WHERE activity_items.target_id = #{id}) AS t
                                ORDER BY created_at DESC", :page => @page, :per_page => @per_page)
  end
end

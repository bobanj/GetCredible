class TwitterContact < ActiveRecord::Base

  # Attributes
  attr_accessible :invited, :screen_name, :name, :avatar

  # Attributes
  belongs_to :user

  # Validations
  validates :twitter_id, presence: true
  validates :screen_name, presence: true

  # Scopes
  scope :ordered, order('name ASC')

  def self.search(params)
    scope = scoped
    if params[:q].present?
      scope = scope.search_by_name_or_screen_name(params[:q])
    end
    scope = scope.paginate(:per_page => 25, :page => params[:page])

    scope.ordered
  end

  def self.search_by_name_or_screen_name(q)
    where("UPPER(twitter_contacts.name) LIKE UPPER(:q) OR
           UPPER(twitter_contacts.screen_name) LIKE UPPER(:q)",
           {:q => "%#{q}%"})
  end
end

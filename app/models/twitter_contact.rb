class TwitterContact < ActiveRecord::Base

  # Attributes
  attr_accessible :invited, :screen_name, :name, :avatar

  # Attributes
  belongs_to :user

  # Validations
  validates :twitter_id, presence: true
  validates :screen_name, presence: true, length: {maximum: 255}
  validates :name, length: {maximum: 255}
  validates :avatar, length: {maximum: 255}

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
    where("UPPER(contacts.name) LIKE UPPER(:q) OR
           UPPER(contacts.screen_name) LIKE UPPER(:q)",
           {:q => "%#{q}%"})
  end
end

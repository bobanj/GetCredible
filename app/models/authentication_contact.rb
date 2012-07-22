class AuthenticationContact < ActiveRecord::Base
  # Attributes
  attr_accessible :authentication_id, :contact_id, :invited

  # Associations
  belongs_to :authentication
  belongs_to :contact

  # Validations
  validates :authentication_id, presence: true
  validates :contact_id, presence: true
  validates_uniqueness_of :authentication_id, scope: :contact_id

  # Class Methods
  def self.search(params)
    scope = scoped.joins(:contact)
    if params[:q].present?
      scope = scope.search_by_name_or_screen_name(params[:q])
    end
    scope = scope.order("contacts.name ASC")
    scope.paginate(:per_page => 25, :page => params[:page])
  end

  def self.search_by_name_or_screen_name(q)
    where("UPPER(contacts.name) LIKE UPPER(:q) OR
           UPPER(contacts.screen_name) LIKE UPPER(:q)",
          {:q => "%#{q}%"})
  end

end

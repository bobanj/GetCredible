class Users::InvitationsController < Devise::InvitationsController
  before_filter :authenticate_inviter!, :only => [:new, :create]
  before_filter :has_invitations_left?, :only => [:create]
  before_filter :require_no_authentication, :only => [:edit, :update]
  before_filter :get_invited_users, :only => [:new, :create]
  helper_method :after_sign_in_path_for

  # GET /resource/invitation/new
  def new
    build_resource
    render :new
  end

  # POST /resource/invitation
  def create
    params[:user][:tag_names] = [params[:tag1].presence,
      params[:tag2].presence, params[:tag3].presence].compact

    self.resource = build_resource(params[resource_name])
    resource.valid?
    resource.errors.add(:tag_names, 'Please add tags') if resource.tag_names.blank?
    if resource.errors[:email].blank? && resource.errors[:tag_names].blank?
      self.resource = resource_class.invite!(params[resource_name], current_inviter)
    end
    if resource.errors.empty?
      set_flash_message :notice, :send_instructions, :email => self.resource.email
      tag_names = TagCleaner.clean(resource.tag_names)
      tag_names.each do |tag_name|
        tag = Tag.find_or_create_by_name(tag_name)
        user_tag = resource.user_tags.new
        user_tag.tag = tag
        user_tag.tagger = current_inviter
        current_inviter.add_vote(user_tag, false) if user_tag.save
      end
      redirect_to new_user_invitation_path
    else
      if resource.errors[:email].present?
        if params[resource_name] && params[resource_name][:email].present?
          resource.errors[:email].clear
          resource.errors[:email] = "has already been invited or registered"
        end
      end
      respond_with_navigational(resource) { render :new }
    end
  end

  # GET /resource/invitation/accept?invitation_token=abcdef
  def edit
    if params[:invitation_token] && self.resource = resource_class.to_adapter.find_first(:invitation_token => params[:invitation_token])
      render :edit
    else
      set_flash_message(:alert, :invitation_token_invalid)
      redirect_to after_sign_out_path_for(resource_name)
    end
  end

  # PUT /resource/invitation
  def update
    self.resource = resource_class.accept_invitation!(params[resource_name])

    if resource.errors.empty?
      set_flash_message :notice, :updated
      sign_in(resource_name, resource)
      #respond_with resource, :location => after_accept_path_for(resource)
      respond_with resource, :location => me_user_path(resource, :show_tour => true)
    else
      respond_with_navigational(resource) { render :edit }
    end
  end

  protected
  def current_inviter
    @current_inviter ||= authenticate_inviter!
  end

  def has_invitations_left?
    unless current_inviter.nil? || current_inviter.has_invitations_left?
      build_resource
      set_flash_message :alert, :no_invitations_remaining
      respond_with_navigational(resource) { render :new }
    end
  end

  def after_invite_path_for(resource)
    after_sign_in_path_for(resource)
  end

  def after_accept_path_for(resource)
    after_sign_in_path_for(resource)
  end

  def get_invited_users
    @invited_users = User.where(:invited_by_id => current_user.id).order("invitation_sent_at desc")
  end
end

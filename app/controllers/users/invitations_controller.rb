class Users::InvitationsController < Devise::SessionsController
  helper_method :after_sign_in_path_for

  # POST /resource/invitation
  def create
    resource = resource_class.invite!(params[resource_name], nil)

    if resource.errors.empty?
      sign_in(:user, resource)
      respond_to do |format|
        format.json do
          render :json => user_signed_in_content(resource)
        end
      end
    else
      respond_to do |format|
        format.json do
          render :json => { :success => false,
                            :errors => resource.errors.full_messages }
        end
      end
    end
  end

  # GET /resource/invitation/accept?invitation_token=abcdef
  def edit
    if params[:invitation_token] && self.resource = resource_class.to_adapter.find_first( :invitation_token => params[:invitation_token] )
      render 'devise/invitations/edit'
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
      respond_with resource, :location => after_accept_path_for(resource)
    else
      respond_with_navigational(resource){ render 'devise/invitations/edit' }
    end
  end

  protected
    def after_invite_path_for(resource)
      after_sign_in_path_for(resource)
    end

    def after_accept_path_for(resource)
      after_sign_in_path_for(resource)
    end
end

class Users::InvitationsController < Devise::InvitationsController

  def create
    @message = EmailMessage.new(params[:email_message].merge(inviter: current_user))

    if @message.save
      render :create_success
    else
      render :create_error
    end
  end

  def after_accept_path_for(resource)
    me_user_path(resource, :show_tour => true)
  end
end

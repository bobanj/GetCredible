class Users::RegistrationsController < Devise::RegistrationsController

  def create
    build_resource

    if resource.save
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_in(resource_name, resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!
      end

      UserMailer.welcome_email(resource).deliver

      respond_to do |format|
        format.html { redirect_to after_sign_in_path_for(resource) }
        format.json { render :json => user_signed_in_content(resource) }
      end
    else
      respond_to do |format|
        format.html { super }
        format.json do
          clean_up_passwords resource
          render :json => {:status => false,
                           :errors => resource.errors.full_messages}
        end
      end
    end
  end

  def update
    @user = User.find(current_user.id)
    if @user.update_attributes(params[:user])
      flash[:notice] = "You have updated your profile successfully."
      # Sign in the user by passing validation in case his password changed
      sign_in @user, :bypass => true
      redirect_to root_path
    else
      render "edit"
    end
  end
end

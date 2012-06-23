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
    if current_user.update_attributes(params[:user])
      respond_to do |format|
        format.html do
          flash[:notice] = 'You have updated your profile successfully.'
          # Sign in the user by passing validation in case his password changed
          sign_in current_user, :bypass => true
          redirect_to me_user_path(current_user)
        end
        format.js {
          @message = 'You have updated your profile successfully.'
          render :layout => false, :status => :ok
          if remotipart_submitted?
            puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@2"
            puts "REMOTIPART"
            puts "@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@2"
          end
        }
        format.json do
          if current_user.changed?
            render :json => {:status => 'ok', :messages => ['You have updated your profile successfully.']}
          else
            render :json => {:status => "same", :messages => ['No changes']}
          end
        end
      end
    else
      respond_to do |format|
        format.html do
          render "edit"
        end
        format.js {
          @message = current_user.errors.full_messages.first
          @current_step = params[:current_step]
          @next_step = params[:next_step]
          #if remotipart_submitted?
            render :layout => false, :status => :unprocessable_entity
          #end
        }
        format.json do
          render :json => {:status => 'error', :messages => current_user.errors.full_messages}
        end
      end
    end
  end
end

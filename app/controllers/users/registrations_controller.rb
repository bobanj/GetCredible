class Users::RegistrationsController < Devise::RegistrationsController

  def create
    build_resource

    if resource.save
      if resource.active_for_authentication?
        set_flash_message :notice, :signed_up if is_navigational_format?
        sign_in(resource_name, resource)

        respond_to do |format|
          format.html { super }
          format.json { render :json => user_signed_in_content(resource) }
        end
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
        expire_session_data_after_sign_in!

        respond_to do |format|
          format.html { super }
          format.json { render :json => user_signed_in_content(resource) }
        end
      end
    else
      clean_up_passwords resource

      respond_to do |format|
        format.html { super }
        format.json do
          render :json => {:status => false,
                           :errors => resource.errors.full_messages}
        end
      end
    end
  end
end

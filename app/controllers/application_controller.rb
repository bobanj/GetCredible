class ApplicationController < ActionController::Base
  protect_from_forgery

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  def after_sign_in_path_for(resource)
    location = stored_location_for(:user)

    if location
      location
    elsif resource.full_name.blank?
      edit_user_registration_path
    else
      all_user_path(resource)
    end
  end

  private
    def user_signed_in_content(resource)
      @user = User.find(params[:user_id])
      {
        :success => true,
        :user => resource,
        :header => render_to_string(:layout => false, :partial => 'shared/header',
                                    :formats => [:html], :handlers => [:haml]),
        :tag_cloud => render_to_string(:layout => false, :partial => 'shared/tag_cloud',
                                       :formats => [:html], :handlers => [:haml])
      }
    end
end

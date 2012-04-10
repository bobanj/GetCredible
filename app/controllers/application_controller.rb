class ApplicationController < ActionController::Base
  protect_from_forgery

  # Devise
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
end

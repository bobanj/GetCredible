class ApplicationController < ActionController::Base
  protect_from_forgery

  # Devise
  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  def after_sign_in_path_for(resource)
    stored_location_for(:user) || resource.full_name.blank? ? edit_user_registration_path : user_path(resource)
  end

end

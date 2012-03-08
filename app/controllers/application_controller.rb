class ApplicationController < ActionController::Base
  protect_from_forgery

  # Devise
  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  def after_sign_in_path_for(resource)
    stored_location_for(:user) || home_show_profile_path
  end

end

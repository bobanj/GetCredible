class ApplicationController < ActionController::Base
  protect_from_forgery

  def after_sign_out_path_for(resource_or_scope)
    root_path
  end

  def after_sign_in_path_for(resource)
    location = stored_location_for(:user)

    if location
      location
    else
      show_tour = current_user.sign_in_count == 1 ? true : nil

      if current_user.user_tags.exists?
        activity_path('all', :show_tour => show_tour)
      else
        me_user_path(current_user, :show_tour => show_tour)
      end
    end
  end

  private
    def user_signed_in_content(resource)
      self.formats = [:html] # let partials resolve with html not json format
      @user = User.find_by_username!(params[:user_id])
      {
        :show_tour => resource.sign_in_count == 1,
        :success => true,
        :user => resource,
        :header => render_to_string(:layout => false, :partial => 'shared/header.html.haml'),
        :tag_cloud => render_to_string(:layout => false, :partial => 'shared/tag_cloud.html.haml')
      }
    end
end

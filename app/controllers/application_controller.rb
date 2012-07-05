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
      sign_in_url
    end
  end

  private
    def user_signed_in_content(resource)
      self.formats = [:html] # let partials resolve with html not json format
      @user = User.find_by_username!(params[:user_id])
      @user_tags = @user.user_tags.joins(:endorsements).group("user_tags.id").includes(:tag, :endorsements => :endorser)

      {
        :own_profile => @user == resource,
        :show_guide => resource.sign_in_count == 1,
        :success => true,
        :user => resource,
        :header => render_to_string(:layout => false, :partial => 'shared/header.html.haml'),
        :tag_cloud => render_to_string(:layout => false, :partial => 'shared/tag_cloud.html.haml'),
        :endorsements => render_to_string(:layout => false, :partial => 'shared/endorsements.html.haml')
      }
    end

    def sign_in_url
      show_guide = current_user.sign_in_count == 1 ? true : nil

      if show_guide || !current_user.user_tags.exists?
        me_user_path(current_user, :show_guide => show_guide)
      else
        activity_path('all')
      end
    end
end

class SessionsController < Devise::SessionsController

  def create
    respond_to do |format|
      format.html do
        super
      end
      format.json do
        resource = warden.authenticate!(:scope => resource_name,
                                        :recall => "#{controller_path}#failure")
        sign_in(resource_name, resource)
        @user = find_viewed_user(request.referrer)
        render :json => { :success => true,
                          :user => resource,
                          :header => render_to_string(:layout => false,
                                     :partial => 'shared/header.html.haml'),
                          :tag_cloud => render_to_string(:layout => false,
                                     :partial => 'shared/tag_cloud.html.haml') }

      end
    end
  end

  def failure
    render :json => { :success => false,
                      :errors => ["Invalid email or password."] }
  end

  private
    def find_viewed_user(referrer)
      route_params = Rails.application.routes.recognize_path(referrer)
      @user = User.find_by_slug(route_params[:id])
    end
end

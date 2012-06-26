class Users::SessionsController < Devise::SessionsController

  def create
    respond_to do |format|
      format.html do
        super
        flash.delete(:notice)
      end
      format.json do
        resource = warden.authenticate!(:scope => resource_name,
                                        :recall => "#{controller_path}#failure")
        sign_in(resource_name, resource)
        render :json => user_signed_in_content(resource)
      end
    end
  end

  def failure
    render :json => { :success => false,
                      :errors => ["Invalid email or password."] }
  end

  def destroy
    super
    flash.delete(:notice)
  end
end

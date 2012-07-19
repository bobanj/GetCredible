class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  before_filter :check_current_user

  def twitter
    oauthorize
  end

  def linkedin
    oauthorize
  end

  def facebook
    oauthorize
  end

  def failure
    redirect_to invite_path
  end

  def disconnect
    if current_user.disconnect_from_provider(params[:provider])
      flash[:notice] = "You have successfully disconnected your #{params[:provider]} account."
    else
      flash[:notice] = "We are in the middle of processing your previous import. Please try again later."
    end
    redirect_to invite_url
  end

  private

  def oauthorize
    omniauth = env["omniauth.auth"]
    authentication = current_user.authentications.find_by_provider_and_uid(omniauth['provider'], omniauth['uid']) ||
        current_user.authentications.create(auth_attributes(omniauth))
    current_user.update_attribute(:"#{authentication.provider}_state", 'pending')
    authentication.import_contacts
    flash[:notice] = "We'll import your contacts from #{authentication.provider} shortly."
    render 'callback', layout: false
  end

  def check_current_user
    redirect_to root_path unless current_user
  end

  def auth_attributes(omniauth)
    {:provider => omniauth['provider'],
    :uid => omniauth['uid'],
    :token => omniauth['credentials']['token'],
    :secret => omniauth['credentials']['secret']}
  end
end

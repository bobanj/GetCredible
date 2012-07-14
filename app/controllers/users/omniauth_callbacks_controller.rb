class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  before_filter :check_current_user

  def twitter
    oauthorize
  end

  def linkedin
    oauthorize
  end

  def failure
    flash.delete(:notice)
    redirect_to invite_path
  end

  private

  def oauthorize
    omniauth = env["omniauth.auth"]
    authentication = current_user.authentications.find_by_provider_and_uid(omniauth['provider'], omniauth['uid']) ||
        current_user.create_authentication(auth_attributes(omniauth))
    authentication.import_contacts
    redirect_to invite_path
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

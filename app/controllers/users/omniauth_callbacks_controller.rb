class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  before_filter :check_current_user

  def twitter
    oauthorize :twitter
  end

  def linkedin
    oauthorize :linkedin
  end

  def failure
    flash.delete(:notice)
    redirect_to invite_path
  end

  private

  def oauthorize(provider)
    case provider
      when :twitter
        omniauth = env["omniauth.auth"]
        authentication = current_user.authentications.find_by_uid(omniauth["uid"]) || current_user.create_omniauth(omniauth)
        authentication.import_contacts
        redirect_to invite_path
      when :linkedin
      else
      raise 'Provider #{provider} not handled'
    end
  end

  def check_current_user
    redirect_to root_path unless current_user
  end
end

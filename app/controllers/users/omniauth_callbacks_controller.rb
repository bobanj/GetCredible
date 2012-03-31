#class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
#  before_filter :authenticate_user!
#
#  def twitter
#    omniauth = request.env["omniauth.auth"]
#    authentication = current_user.authentications.find_by_provider_and_uid(omniauth['provider'], omniauth['uid'])
#    signed_in_resource.apply_omniauth(omniauth) if authentication.blank?
#    flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Twitter"
#    redirect_to edit_user_registration_path
#  end
#end
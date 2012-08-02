class InvitationMessagesController < ApplicationController
  before_filter :authenticate_user!

  def create
    @invitation_message = InvitationMessage.new(params[:invitation_message].
                 merge(inviter: current_user, view_context: view_context))

    if @invitation_message.save
      render :create_success
    else
      render :create_error
    end
  rescue Twitter::Error::Unauthorized
    render :unauthorized
  rescue Twitter::Error::Forbidden => e
    render :api_error, :locals => {:error => e.message}
  rescue Twitter::Error
    render :api_error, :locals => {:error => I18n.t('twitter.errors.unavailable')}
  rescue LinkedIn::Errors::AccessDeniedError
    render :api_error, :locals => {:error => I18n.t('linkedin.errors.access_denied')}
  rescue GiveBrand::MessageSender::FacebookChatAccessDenied
    render :api_error, :locals => {:error => 'Allow "Access Facebook Chat" to invite your Facebook friends.' }
  end

end

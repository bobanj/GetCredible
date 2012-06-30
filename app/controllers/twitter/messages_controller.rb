class Twitter::MessagesController < ApplicationController
  before_filter :authenticate_user!

  def create
    @message = TwitterMessage.new(params[:twitter_message].
                 merge(inviter: current_user, view_context: view_context))

    if @message.save
      render :create_success
    else
      render :create_error
    end
  rescue Twitter::Error::Unauthorized
    render :unauthorized
  rescue Twitter::Error::Forbidden => e
    render :twitter_error, :locals => {:error => e.message}
  rescue Twitter::Error
    render :twitter_error, :locals => {:error => I18n.t('twitter.errors.unavailable')}
  end

end

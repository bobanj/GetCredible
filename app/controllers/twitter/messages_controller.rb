class Twitter::MessagesController < ApplicationController
  before_filter :authenticate_user!

  def create
    client = Gbrand::Twitter::Client.from_oauth_token(
              current_user.twitter_token, current_user.twitter_secret)
    @twitter_contact = current_user.twitter_contacts.
                        find_by_twitter_id!(params[:twitter_id])

    @messanger = Gbrand::Twitter::Messanger.new(@twitter_contact, client)
    @messanger.create(params)
  rescue Twitter::Error::Unauthorized
    render :unauthorized
  rescue Twitter::Error::Forbidden => e
    render :error, :locals => {:error => e.message}
  rescue Twitter::Error
    render :error, :locals => {:error => I18n.t('twitter.errors.unavailable')}
  end

end

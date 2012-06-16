class Twitter::SessionsController < ApplicationController
  before_filter :authenticate_user!

  def new
    request_token = consumer.get_request_token(
                      :oauth_callback => twitter_session_url(:current))
    session[:request_token]  = request_token.token
    session[:request_secret] = request_token.secret
    session[:url] = params[:url] if params[:url].present?

    redirect_to request_token.authorize_url
  end

  def show
    request_token = OAuth::RequestToken.new(consumer,
                      session[:request_token], session[:request_secret])
    access_token  = request_token.get_access_token(
                      :oauth_verifier => params[:oauth_verifier])

    current_user.update_twitter_oauth(access_token.token, access_token.secret)

    url = session[:url].presence || twitter_contacts_url
    session[:url] = nil

    redirect_to url
  end

  def destroy
    current_user.twitter_contacts.destroy_all
    current_user.update_twitter_oauth(nil, nil)
    flash[:notice] = I18n.t('twitter.contacts.remove')
    redirect_to me_user_url(current_user)
  end

  private

  def consumer
    @consumer ||= OAuth::Consumer.new(ENV['TWITTER_CONSUMER_KEY'],
      ENV['TWITTER_CONSUMER_SECRET'], {:site => 'http://twitter.com'})
  end
end

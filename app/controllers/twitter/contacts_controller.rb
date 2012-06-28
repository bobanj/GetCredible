class Twitter::ContactsController < ApplicationController
  before_filter :authenticate_user!

  def index
    client = Gbrand::Twitter::Client.from_oauth_token(current_user.twitter_token, current_user.twitter_secret)

    Gbrand::Twitter::Importer.import(current_user, client)
    flash[:notice] = I18n.t('twitter.contacts.import')
    redirect_to people_invite_url

  rescue Twitter::Error::Unauthorized
    redirect_to new_twitter_session_path(:url => twitter_contacts_url)
  rescue Twitter::Error
    flash[:error] = I18n.t('twitter.errors.unavailable')
    redirect_to people_invite_url
  end
end

class Twitter::ContactsController < ApplicationController
  before_filter :authenticate_user!

  def index
    @contacts = current_user.twitter_contacts.search(params)
    @users = User.where(['twitter_handle IN (?)', @contacts.map(&:screen_name)])

    respond_to do |format|
      format.html do
        render 'index', layout: (request.xhr? ? false : true)
      end
      format.js
    end
  end

  def import
    client = Gbrand::Twitter::Client.from_oauth_token(current_user.twitter_token, current_user.twitter_secret)

    Gbrand::Twitter::Importer.import(current_user, client)
    flash[:notice] = I18n.t('twitter.contacts.import')
    redirect_to twitter_contacts_url

  rescue Twitter::Error::Unauthorized
    redirect_to new_twitter_session_path(:url => import_twitter_contacts_url)
  rescue Twitter::Error
    flash[:error] = I18n.t('twitter.errors.unavailable')
    redirect_to twitter_contacts_url
  end
end

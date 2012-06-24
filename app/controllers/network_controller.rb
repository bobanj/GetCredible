class NetworkController < ApplicationController
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
end

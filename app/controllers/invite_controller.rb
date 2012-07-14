class InviteController < ApplicationController
  before_filter :authenticate_user!

  def index
    @contacts = current_user.twitter_contacts.search(params)
    @users = Authentication.where(["provider = 'twitter' AND uid IN (?)", @contacts.map(&:twitter_id)]).includes(:user).map(&:user)
    @twitter_message = TwitterMessage.new

    respond_to do |format|
      format.html { render layout: (request.xhr? ? false : true) }
      format.js
    end
  end
end

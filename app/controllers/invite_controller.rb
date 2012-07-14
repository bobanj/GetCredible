class InviteController < ApplicationController
  before_filter :authenticate_user!

  def index
    @contacts = current_user.contacts.includes(:authentication).search(params)
    #@users = Authentication.existing_users(@contacts)
    @twitter_message = TwitterMessage.new
    respond_to do |format|
      format.html { render layout: (request.xhr? ? false : true) }
      format.js
    end
  end
end

class InviteController < ApplicationController
  before_filter :authenticate_user!

  def index
    @contacts = current_user.twitter_contacts.search(params)
    @users = User.where(['twitter_id IN (?)', @contacts.map(&:twitter_id)])
    @twitter_message = TwitterMessage.new

    respond_to do |format|
      format.html do
        render layout: (request.xhr? ? false : true)
      end
      format.js
    end
  end
end

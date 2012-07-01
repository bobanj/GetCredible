class PeopleController < ApplicationController
  before_filter :authenticate_user!

  def index
    @users = current_user.supporters.
      paginate :per_page => 10, :page => params[:page]
    render :index, layout: (request.xhr? ? false : true)
  end

  def supported
    @users = current_user.supported.
      paginate :per_page => 10, :page => params[:page]
    render :index, layout: (request.xhr? ? false : true)
  end

  def pending
    @users = current_user.pending.
      paginate :per_page => 10, :page => params[:page]

    render :index, layout: (request.xhr? ? false : true)
  end

  def invite
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

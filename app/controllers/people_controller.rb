class PeopleController < ApplicationController
  before_filter :authenticate_user!

  def index
    @users = current_user.tagged.
      paginate :per_page => 10, :page => params[:page]
    render :index, layout: (request.xhr? ? false : true)
  end

  def tagged_you
    @users = current_user.tagged_you.
      paginate :per_page => 10, :page => params[:page]
    render :index, layout: (request.xhr? ? false : true)
  end

  def pending
    @users = current_user.pending.
      paginate :per_page => 10, :page => params[:page]

    render :index, layout: (request.xhr? ? false : true)
  end

  def invite
    @users = User.where(:invited_by_id => current_user.id).order("invitation_sent_at desc")
    @contacts = current_user.twitter_contacts.search(params)
    @users = User.where(['twitter_handle IN (?)', @contacts.map(&:screen_name)])
    @twitter_message = TwitterMessage.new

    respond_to do |format|
      format.html do
        render layout: (request.xhr? ? false : true)
      end
      format.js
    end
  end
end

class UsersController < ApplicationController

  before_filter :authenticate_user!, :only => :pending
  before_filter :load_user, :only => [:show, :followers, :following]

  def index
    @users = User.search(params)
    render 'index', layout: (request.xhr? ? false : true)
  end

  def show
    @user_tags = @user.user_tags.includes(:tag, :endorsements => :endorser).sort_by{|ut| ut.score.value.to_s}
    render :layout => false if request.xhr?
  end

  def followers
    @users = @user.supporters.
      paginate :per_page => 10, :page => params[:page]
    render :users, layout: (request.xhr? ? false : true)
  end

  def following
    @users = @user.supported.
      paginate :per_page => 10, :page => params[:page]
    render :users, layout: (request.xhr? ? false : true)
  end

  def pending
    @user = current_user
    @users = @user.pending.
      paginate :per_page => 10, :page => params[:page]

    render :users, layout: (request.xhr? ? false : true)
  end

  private
  def load_user
    @user = User.find_by_username!(params[:id])
  end
end

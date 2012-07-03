class UsersController < ApplicationController

  # before_filter :authenticate_user!, :only => [:followers, :following]
  before_filter :load_user, :only => [:show, :followers, :following]

  def index
    @users = User.search(params)
    render 'index', layout: (request.xhr? ? false : true)
  end

  def show
    @user_tags = @user.user_tags.includes(:tag, :endorsements => :endorser).all
    @user_tags = @user_tags.sort_by{ |ut| - ut.endorsements.length }
    @endorsement = Endorsement.new

    render :layout => false if request.xhr?
  end

  def followers
    @users = @user.voters.order_by_name.
      paginate :per_page => 10, :page => params[:page]
    render :users, layout: (request.xhr? ? false : true)
  end

  def following
    @users = @user.voted_users.order_by_name.
      paginate :per_page => 10, :page => params[:page]

    render :users, layout: (request.xhr? ? false : true)
  end

  private
  def load_user
    @user = User.find_by_username!(params[:id])
  end
end

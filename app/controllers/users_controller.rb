class UsersController < ApplicationController
  before_filter :authenticate_user!, :only => [:endorse]
  before_filter :load_user, :only => [:show, :followers, :following, :endorse]

  def index
    @users = User.search(params)

    render 'index', layout: (request.xhr? ? false : true)
  end

  def show
    @user_tag_endorsements = @user.incoming_endorsements.latest.
      includes([:user_tag, :tag, :endorser]).
      group_by{|e| e.user_tag}
    render :layout => false if request.xhr?
  end

  def followers
    users_count = @user.voters.count
    @users = @user.voters.order_by_name.
      paginate :per_page => 10, :page => params[:page]
    @users.instance_variable_set '@total_entries', users_count

    render :users, layout: (request.xhr? ? false : true)
  end

  def following
    users_count = @user.voted_users.count
    @users = @user.voted_users.order_by_name.
      paginate :per_page => 10, :page => params[:page]
    @users.instance_variable_set '@total_entries', users_count

    render :users, layout: (request.xhr? ? false : true)
  end

  private
  def load_user
    @user = User.find_by_username!(params[:id].to_s.downcase)
  end
end

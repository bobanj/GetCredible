class UsersController < ApplicationController

  def index
    @users = User.search(params)
  end

  def show
    @user = User.find(params[:id])
  end

  def incoming
    @user = User.find(params[:id])
    @activity_items = @user.incoming_activities.paginate(:page => params[:page], :per_page => 10)
    render 'activities'
  end

  def outgoing
    @user = User.find(params[:id])
    @activity_items = @user.outgoing_activities.paginate(:page => params[:page], :per_page => 10)
    render 'activities'
  end

  def all
    @user = User.find(params[:id])
    @activity_items = @user.all_activities(:page => params[:page], :per_page => 10)
    render 'activities'
  end
end

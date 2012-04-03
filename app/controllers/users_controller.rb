class UsersController < ApplicationController

  def index
    @users = User.search(params)
  end

  def show
    @user = User.find(params[:id])
    render :layout => false if request.xhr?
  end

  def incoming
    @user = User.find(params[:id])
    @activity_items = @user.incoming_activities.paginate(:page => params[:page], :per_page => 10)
    render 'activities', layout: (request.xhr? ? false : true)
  end

  def outgoing
    @user = User.find(params[:id])
    @activity_items = @user.outgoing_activities.paginate(:page => params[:page], :per_page => 10)
    render 'activities', layout: (request.xhr? ? false : true)
  end

  def all
    @user = User.find(params[:id])
    @activity_items = @user.all_activities(:page => params[:page], :per_page => 10)
    render 'activities', layout: (request.xhr? ? false : true)
  end
end

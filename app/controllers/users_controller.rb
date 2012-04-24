class UsersController < ApplicationController

  def index
    @users = User.search(params)
    render 'index', layout: (request.xhr? ? false : true)
  end

  def show
    @user = User.find(params[:id])
    render :layout => false if request.xhr?
  end
end

class UsersController < ApplicationController

  def index
    @users = User.search(params)
  end

  def show
    @user = User.find(params[:id])
  end
end

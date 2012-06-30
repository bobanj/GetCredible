class UsersController < ApplicationController

  def index
    @users = User.search(params)
    render 'index', layout: (request.xhr? ? false : true)
  end

  def show
    @user = User.find_by_username!(params[:id])
    @user_tags = @user.user_tags.includes(:tag, :endorsements => :endorser).sort_by{|ut| ut.score.value.to_s}
    render :layout => false if request.xhr?
  end
end

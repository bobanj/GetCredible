class FriendshipsController < ApplicationController
  before_filter :authenticate_user!
  before_filter :load_user

  def create
    @friendship = current_user.follow(@user)
  end

  def destroy
    current_user.unfollow(@user)
  end

  private
  def load_user
    @user = User.find_by_username!(params[:user_id])
  end

end

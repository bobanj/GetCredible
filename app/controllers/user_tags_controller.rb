class UserTagsController < ApplicationController

  before_filter :authenticate_user!, :except => [:index]
  before_filter :load_user

  def index
    render json: @user.tags_summary
  end

  def create
    @user.add_tags(params[:tag_names]) if current_user != @user

    render json: @user.tags_summary
  end

  private
    def load_user
      @user = User.find(params[:user_id])
    end
end

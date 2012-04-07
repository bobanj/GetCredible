class UserTagsController < ApplicationController

  before_filter :authenticate_user!, :except => [:index]
  before_filter :load_user

  def index
    render json: @user.tags_summary(current_user)
  end

  def create
    if current_user != @user
      UserTag.add_tags(@user, current_user, params[:tag_names])
    end

    render json: @user.tags_summary(current_user)
  end

  def vote
    user_tag = UserTag.find(params[:id])
    vote = current_user.add_vote(user_tag)
    if vote
      render json: {:votes => user_tag.votes.sum(:weight).to_i, :status => 'ok'}.to_json
    else
      render json: {status: 'error'}.to_json
    end
  end

  def unvote
    user_tag = UserTag.find(params[:id])

    if current_user.remove_vote(user_tag)
      render json: {:votes => user_tag.votes.sum(:weight).to_i, status: 'ok'}.to_json
    else
      render json: {status: 'error'}.to_json
    end
  end

  def destroy
    user_tag = current_user.user_tags.find_by_id(params[:id])
    user_tag.destroy
    render json: @user.tags_summary(current_user)
  end

  private
    def load_user
      @user = User.find(params[:user_id])
    end
end

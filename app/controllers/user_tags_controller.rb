class UserTagsController < ApplicationController

  before_filter :authenticate_user!, :except => [:index]
  before_filter :load_user

  def index
    render json: @user.tags_summary(current_user)
  end

  def create
    @user.add_tags(params[:tag_names]) if current_user != @user

    render json: @user.tags_summary(current_user)
  end

  def vote
    user_tag = UserTag.find(params[:id])
    if current_user != user_tag.user
      current_user.vote_exclusively_for(user_tag)
      render json: {status: 'ok'}.to_json
    else
      render json: {status: 'error'}.to_json
    end
  end

  def unvote
    user_tag = UserTag.find(params[:id])
    vote = user_tag.votes.for_voter(current_user).first
    if vote
      vote.destroy
      render json: {status: 'ok'}.to_json
    else
      render json: {status: 'error'}.to_json
    end
  end

  private
    def load_user
      @user = User.find(params[:user_id])
    end
end

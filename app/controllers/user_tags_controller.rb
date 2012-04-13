class UserTagsController < ApplicationController

  before_filter :authenticate_user!, :except => [:index]
  before_filter :load_user

  def index
    render json: @user.tags_summary(current_user)
  end

  def create
    if current_user != @user
      tag_names = TagCleaner.clean(params[:tag_names])
      UserTag.add_tags(@user, current_user, tag_names)
      UserMailer.tag_email(current_user, @user, tag_names).deliver
    end

    render json: @user.tags_summary(current_user)
  end

  def vote
    user_tag = @user.user_tags.find(params[:id])
    vote = current_user.add_vote(user_tag)
    if vote
      UserMailer.vote_email(current_user, @user, user_tag.tag.name).deliver
      render json: {:votes => user_tag.calculate_votes, :status => 'ok'}.to_json
    else
      render json: {status: 'error'}.to_json
    end
  end

  def unvote
    user_tag = @user.user_tags.find(params[:id])

    if user_tag && current_user.remove_vote(user_tag)
      render json: {:votes => user_tag.calculate_votes, status: 'ok'}.to_json
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

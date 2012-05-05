class UserTagsController < ApplicationController
  include UserTagsHelper

  before_filter :authenticate_user!, :except => [:index]
  before_filter :load_user

  def index
    render json: tags_summary(@user, current_user)
  end

  def create
    if current_user != @user
      tag_names = TagCleaner.clean(params[:tag_names])
      current_user.add_tags(@user, tag_names)
    end

    render json: tags_summary(@user, current_user)
  end

  def vote
    user_tag = @user.user_tags.find(params[:id])
    vote = current_user.add_vote(user_tag)
    if vote
      render json: tag_summary(user_tag, @user, current_user).merge({:status => 'ok'}).to_json
    else
      render json: {status: 'error'}.to_json
    end
  end

  def unvote
    user_tag = @user.user_tags.find(params[:id])

    if user_tag && current_user.remove_vote(user_tag)
      render json: tag_summary(user_tag, @user, current_user).merge({:status => 'ok'}).to_json
    else
      render json: {status: 'error'}.to_json
    end
  end

  def destroy
    user_tag = current_user.user_tags.find_by_id(params[:id])
    user_tag.destroy
    render json: tags_summary(@user, current_user)
  end

  private
    def load_user
      @user = User.find(params[:user_id])
    end
end

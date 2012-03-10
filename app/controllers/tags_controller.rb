class TagsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :load_user

  # TODO: render tags for the cloud
  def index
    render json: prepare_user_tags(@user.user_tags)
  end

  def create
    @user.add_tags(params[:tag_names])

    render json: prepare_user_tags(@user.user_tags)
  end

  private
    def load_user
      @user = User.find(params[:user_id])
    end

    def prepare_user_tags(user_tags)
      tags = []

      user_tags.includes(:tag).each do |user_tag|
        tags << {
          name: user_tag.tag.name,
          votes: 1
        }
      end

      tags
    end
end

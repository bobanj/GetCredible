class TagsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :load_user

  # TODO: render tags for the cloud
  # def index
  # end

  def create
    @user.tag(params[:tag_names])

    # TODO return new tags for the cloud
    render json: {status: 'ok'}.to_json
  end

  private
    def load_user
      @user = User.find(params[:user_id])
    end
end

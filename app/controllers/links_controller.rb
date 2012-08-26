class LinksController < ApplicationController
  before_filter :authenticate_user!

  def create
    @link = current_user.links.new(params[:link])

    if @link.save
      ActivityItem.create(user: current_user, item: @link,
                          target: current_user, tags: @link.tags)
      render :create_success
    else
      render :create_failure
    end
  end
end

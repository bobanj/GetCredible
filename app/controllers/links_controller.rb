class LinksController < ApplicationController
  before_filter :authenticate_user!, except: [:index]

  def index
    @user = User.find_by_username!(params[:id])
    @links = @user.links.includes(:tags).ordered.
        paginate :per_page => 3, :page => params[:page]
    render layout: (request.xhr? ? false : true)
  end

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

  def destroy
    @link = current_user.links.find(params[:id])

    @link.destroy
    flash[:notice] = "Link was successfully deleted"
    redirect_to me_user_links_path(current_user)
  end
end
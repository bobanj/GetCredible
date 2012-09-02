class HomeController < ApplicationController
  include PreloaderHelper

  def index
    if user_signed_in?
      redirect_to activity_path('all')
    else
      @activity_items = ActivityItem.active.ordered.
        paginate page: params[:page], per_page: 10
      preload_activity_items(@activity_items)

      render 'index', layout: (request.xhr? ? false : true)
    end
  end

  def privacy
  end

  def terms
  end

  def tour
  end

  def press
  end

  def team
  end

  def about
  end

  def sitemap
  end
end

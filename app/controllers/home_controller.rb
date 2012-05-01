class HomeController < ApplicationController
  include UserTagsHelper

  def index
    if user_signed_in?
      redirect_to activity_path('all')
    else
      @activity_items = ActivityItem.order("created_at desc").
        paginate(:per_page => 10, :page => 1)
      preload_associations(@activity_items)
    end
  end

  def privacy
  end

  def terms
  end
end

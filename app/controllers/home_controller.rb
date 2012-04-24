class HomeController < ApplicationController

  def index
    if user_signed_in?
      redirect_to activity_path('all')
    else
      @activity_items = ActivityItem.order("created_at desc").
        paginate(:per_page => 10, :page => 1)
    end
  end
end

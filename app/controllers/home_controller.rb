class HomeController < ApplicationController

  def index
    @activity_items = ActivityItem.order("created_at desc").
      paginate(:per_page => 10, :page => 1)
  end
end

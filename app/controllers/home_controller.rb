class HomeController < ApplicationController
  def index
    @activity_items = ActivityItem.order("created_at desc").paginate(:per_page => 10, :page => 1)
  end

  def activity
  end

  def show_profile
  end

  def edit_profile
  end

  def invite_email
  end

  def invite_twitter
  end

  def search
  end

end

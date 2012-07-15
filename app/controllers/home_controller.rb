class HomeController < ApplicationController

  def index
    if user_signed_in?
      redirect_to activity_path('all')
    else
      render layout: "landing"
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

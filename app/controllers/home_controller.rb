class HomeController < ApplicationController

  def index
    redirect_to activity_path('all') if user_signed_in?
  end

  def privacy
  end

  def terms
  end

  def tour
  end

  def press
  end
end

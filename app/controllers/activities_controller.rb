class ActivitiesController < ApplicationController
  ACTIVITIES_PER_PAGE = 10

  before_filter :authenticate_user!

  def show
    case params[:id]
    when 'all'
      @activity_items = current_user.
        all_activities(:page => params[:page], :per_page => ACTIVITIES_PER_PAGE)
    when 'incoming'
      @activity_items = current_user.incoming_activities.
        paginate(:page => params[:page], :per_page => ACTIVITIES_PER_PAGE)
    when 'outgoing'
      @activity_items = current_user.outgoing_activities.
        paginate(:page => params[:page], :per_page => ACTIVITIES_PER_PAGE)
    end
  end
end

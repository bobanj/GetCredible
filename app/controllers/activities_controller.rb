class ActivitiesController < ApplicationController
  include PreloaderHelper

  before_filter :authenticate_user!

  def show
    @activity_items = load_activity_items
    preload_activity_items(@activity_items)

    render 'index', layout: (request.xhr? ? false : true)
  end

  private
    def load_activity_items
      case params[:id]
      when 'incoming'
        current_user.incoming_activities_for_others.paginate(paginate_options)
      when 'outgoing'
        current_user.outgoing_activities.paginate(paginate_options)
      when 'all'
        current_user.all_activities.paginate(paginate_options)
      else
        raise ActiveRecord::RecordNotFound
      end
    end

    def paginate_options
      { page: params[:page], per_page: 10 }
    end
end

class ActivitiesController < ApplicationController
  include UserTagsHelper

  before_filter :authenticate_user!

  def show
    @activity_items = load_activity_items
    preload_associations(@activity_items)
    render 'index', layout: (request.xhr? ? false : true)
  end

  private
    def load_activity_items
      case params[:id]
      when 'incoming'
        current_user.incoming_activities.paginate(:page => params[:page], :per_page => 10)
      when 'outgoing'
        current_user.outgoing_activities.paginate(:page => params[:page], :per_page => 10)
      when 'all'
        current_user.all_activities(:page => params[:page], :per_page => 10)
      else
        raise ActiveRecord::RecordNotFound
      end
    end
end

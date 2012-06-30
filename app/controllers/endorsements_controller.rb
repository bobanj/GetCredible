
class EndorsementsController < ApplicationController
  before_filter :authenticate_user!

  def create
    @endorsement = Endorsement.new(params[:endorsement])
    @endorsement.endorser = current_user

    respond_to do |format|
      if @endorsement.save
        @success = true
        format.js {
          render :create
        }
      else
        @success = false
        format.js {
          render :create
        }
      end
    end
  end

  def new
    @endorsement = Endorsement.new
  end

end

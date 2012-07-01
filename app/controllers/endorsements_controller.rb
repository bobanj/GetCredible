
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

  def destroy
    @endorsement = current_user.incoming_endorsements.find_by_id(params[:id])
    if @endorsement
      @endorsement.destroy
      render json: {status: 'ok'}
    else
      render json: {status: 'error'}
    end

  end

end

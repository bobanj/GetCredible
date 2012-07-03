class EndorsementsController < ApplicationController
  before_filter :authenticate_user!

  def edit
    @endorsement = current_user.outgoing_endorsements.find(params[:id])
  end

  def create
    @endorsement = Endorsement.new(params[:endorsement])
    @endorsement.endorser = current_user

    respond_to do |format|
      if @endorsement.save
        @endorsement.endorser.activity_items.create(:item => @endorsement, :target_id => @endorsement.user_tag.user_id)
        format.js { render :create_success }
      else
        format.js { render :create_failure }
      end
    end
  end

  def update
    @endorsement = current_user.outgoing_endorsements.find(params[:id])

    respond_to do |format|
      if @endorsement.update_attributes(params[:endorsement])
        format.js { render :update_success }
      else
        format.js { render :update_failure }
      end
    end
  end

  def destroy
    @endorsement = current_user.incoming_endorsements.find_by_id(params[:id])
    if @endorsement
      @endorsement.destroy
      render json: {status: 'ok', user_tag_id: @endorsement.user_tag_id}
    else
      render json: {status: 'error', user_tag_id: @endorsement.user_tag_id}
    end

  end

end

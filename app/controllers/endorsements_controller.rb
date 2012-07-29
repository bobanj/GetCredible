class EndorsementsController < ApplicationController

  before_filter :authenticate_user!
  before_filter :load_user

  def edit
    @endorsement = current_user.outgoing_endorsements.find(params[:id])
  end

  def create
    @endorsement = current_user.outgoing_endorsements.new(params[:endorsement])

    if @endorsement.save
      current_user.activity_items.create(:item => @endorsement,
                                :target_id => @user.id)
      UserMailer.endorse_email(@endorsement).deliver
      render :create_success
    else
      render :create_failure
    end
  end

  def update
    @endorsement = current_user.outgoing_endorsements.find(params[:id])

    if @endorsement.update_attributes(params[:endorsement])
      render :update_success
    else
      render :update_failure
    end
  end

  def destroy
    @endorsement = current_user.incoming_endorsements.find(params[:id])
    @endorsement.destroy
  end

  private
  def load_user
    @user = User.find_by_username!(params[:user_id])
  end

end

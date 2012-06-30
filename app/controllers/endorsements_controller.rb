
class EndorsementsController < ApplicationController
  before_filter :authenticate_user!

  def create
    @endorsement = Endorsement.new(params[:endorsement])
    if @endorsement.user_tag.user_id == current_user.id
      @endorsement.errors.add(:base, "You can't endorse yourself'");
    end

    respond_to do |format|
      if @endorsement.save
        @success = true
        format.js {
          render :create
        }
      else
        @success = false

        puts @endorsement.errors.full_messages
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

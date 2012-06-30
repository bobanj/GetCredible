
class EndorsementsController < ApplicationController
  def create
    @endorsement = Endorsement.new(params[:endorsement])

    respond_to do |format|
      if @endorsement.save
        format.html {
          render :partial => :show
        }
      else
        format.html { render :partial => :new }
      end
    end
  end
end

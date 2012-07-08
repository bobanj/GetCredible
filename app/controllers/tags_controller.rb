class TagsController < ApplicationController

  def search
    render :json => Tag.search(params['term'])
  end
end

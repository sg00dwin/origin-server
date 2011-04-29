class VideoController < ApplicationController

  def show
    # TODO - check that video exists
    @filename = params[:name]
  end

end

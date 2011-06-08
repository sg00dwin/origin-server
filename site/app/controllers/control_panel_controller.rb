class ControlPanelController < ApplicationController

  #todo - check for logged in/ out status

  def index
    @domain = ExpressDomain.new()
  end

end

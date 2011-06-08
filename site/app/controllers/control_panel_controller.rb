class ControlPanelController < ApplicationController

  def index
    @domain = ExpressDomain.new()
  end

end

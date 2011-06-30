class ControlPanelController < ApplicationController
  before_filter :require_login

  def index
    @domain = ExpressDomain.new()
  end

end

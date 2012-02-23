class StyleguideController < ApplicationController
  layout 'styleguide'

  def index
  end

  def forms
  end

  def loading
  end

  def slow
    sleep 3
    redirect_to :action => "index", :controller => "styleguide"
  end
end

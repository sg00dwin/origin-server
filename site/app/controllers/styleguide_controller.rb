class StyleguideController < ApplicationController
  layout 'styleguide'

  def index
  end

  def forms
  end

  def loading
  end

  def community
  end

  def community_real
  end

  def home
  end

  def signup
  end

  def slow
    sleep 3
    redirect_to :action => "index", :controller => "styleguide"
  end
end

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

  def home
  end

  def overview
    render :layout => 'site'
  end

  def signup
  end

  def fonts
    render :layout => nil
  end

  def landing
    render :layout => nil
  end

  def slow
    sleep 3
    redirect_to :action => "index", :controller => "styleguide"
  end
end

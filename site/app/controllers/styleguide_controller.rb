class StyleguideController < ApplicationController
  layout 'styleguide'
  before_filter :require_login, :only => :technologies

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

  def technologies
    types = ApplicationType.find(:all, :as => session_user)
    p_t, types = types.partition {|t| t.categories.include? :productivity }
    carts = CartridgeType.embedded(:as => session_user)
    carts.reject! {|t| ([:blacklist, :experimental] & t.categories).present? }
    d, carts = carts.partition {|t| t.categories.include?(:database)}
    a, carts = carts.partition {|t| t.categories.include?(:administration)}
    p, carts = carts.partition {|t| t.categories.include?(:productivity)}

    logger.debug carts.inspect

    @sections = [
      {:name => "Web Platforms", :data => types.select {|t| t.categories.include?(:framework)}},
      {:name => "Databases", :data => d },
      {:name => "Administration", :data => a },
      {:name => "Developer Productivity", :data => p_t + p },
      {:name => "Other", :data => carts },
    ]
    render :layout => 'site'
  end

  def slow
    sleep 3
    redirect_to :action => "index", :controller => "styleguide"
  end
end

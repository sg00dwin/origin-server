class SiteController < ApplicationController

  layout 'site'

  before_filter :new_forms, :only => [ :show, :signup, :signin ]

  def active_tab
    @active_tab
  end
end

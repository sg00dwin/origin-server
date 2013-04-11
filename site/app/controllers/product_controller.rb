class ProductController < SiteController

  def index
    redirect_to community_url
  end

  def legacy_redirect
    redirect_to community_base_url(params[:route])
  end

  def not_found
  end

  def error
    render 'console/error'
  end

  def console_not_found
    render 'console/not_found', :layout => 'console'
  end

  def console_error
    render 'console/error', :layout => 'console'
  end

  [
    :core_error, :core_not_found, :core_unavailable, 
    :core_app_error, :core_app_unavailable, :core_app_installing
  ].each do |sym|
    define_method sym do 
      render :layout => nil
    end
  end
end

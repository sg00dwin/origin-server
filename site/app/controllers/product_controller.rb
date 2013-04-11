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

  def core_error
    render :layout => nil
  end
  def core_not_found
    render :layout => nil
  end
  def core_unavailable
    render :layout => nil
  end
  def core_app_error
    render :layout => nil
  end
end

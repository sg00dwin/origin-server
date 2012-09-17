class ProductController < SiteController

  def index
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
end

class ProductController < SiteController

  def index
  end

  def not_found
  end

  def error
  end

  def console_not_found
    render :layout => 'console'
  end

  def console_error
    render :layout => 'console'
  end
end

class ProductController < SiteController

  def index
  end

  def not_found
    render 'shared/not_found'
  end

  def error
    render 'shared/error'
  end

  def console_not_found
    render 'shared/not_found', :layout => 'console'
  end

  def console_error
    render 'shared/error', :layout => 'console'
  end
end

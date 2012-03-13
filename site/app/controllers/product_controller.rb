class ProductController < SiteController

  def express
    # Handle the email confirmation flow
    @product = 'express'
    @register_url = user_new_express_url
    
    if session[:confirm_flow]
      session.delete(:confirm_flow)
      flash[:notice] = "Almost there!  Login to complete your registration."
      require_login and return
    end
  end
  
  def flex_redirect
    redirect_to '/flex' and return
  end
  
  def flex
    @product = 'flex'
    @register_url = user_new_flex_url
    
    # Handle the email confirmation flow
    if session[:confirm_flow]
      session.delete(:confirm_flow)
      flash[:notice] = "Almost there!  Login to complete your registration."
      require_login and return
    elsif workflow_redirect
      # Handles flex redirecting back to /app/flex
      return
    end
  end

  #Product overview page
  def overview
    render :action => :overview
  end
  
  #Feature matrix
  def features
    render :action => :features, :layout => 'application'
  end
  
end

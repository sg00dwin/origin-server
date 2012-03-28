class GettingStartedExternalController < SiteController
  
  before_filter :require_login
  
  def show
    registration_referrer = (params[:registration_referrer] || '').gsub('[^a-zA-Z_]','')
    render registration_referrer and return
  end
  
end

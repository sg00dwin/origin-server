require 'pp'

class Access::ExpressRequestController < Access::AccessRequestController
  before_filter :set_no_cache

  def setup_new_model
    @access = Access::ExpressRequest.new
  end
  
  def new_path
    new_access_express_requests_path
  end
  
  def getting_started_path
    getting_started_express_path
  end
  
  def setup_create_model(params)
    ae = params[:access_express_request]
    @access = Access::ExpressRequest.new(ae ? ae : {})
  end
  
  def access_type
    CloudAccess::EXPRESS
  end
  
  def request_access
    @user.request_access(access_type)
  end
  
end

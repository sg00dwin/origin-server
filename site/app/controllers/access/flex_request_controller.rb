require 'pp'

class Access::FlexRequestController < Access::AccessRequestController
  before_filter :set_no_cache
  
  def setup_new_model
    @access = Access::FlexRequest.new
  end
  
  def new_path
    new_access_flex_requests_path
  end
  
  def getting_started_path
    getting_started_flex_path
  end
  
  def setup_create_model(params)
    af = params[:access_flex_request]
    @access = Access::FlexRequest.new(af ? af : {})
  end
  
  def access_type
    CloudAccess::FLEX
  end
  
  def request_access
    @user.request_access(access_type)
  end

end

require 'pp'

class Access::ExpressRequestController < Access::AccessRequestController
  before_filter :set_no_cache
  
  def request_direct
    @new_path = access_express_request_direct_path
    new do
      if @user.terms.empty?
        execute_request_access do
          if @user.has_requested?(access_type)
            render :create and return
          elsif @user.has_access?(access_type)
            redirect_to getting_started_path and return
          end
        end
      end
    end
  end

  def setup_new_model
    @access = Access::ExpressRequest.new
  end
  
  def new_path
    if !@new_path         
      return new_access_express_requests_path
    else
      return @new_path
    end
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

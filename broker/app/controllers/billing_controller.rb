class BillingController < BaseController
  before_filter :protect

  def protect
    Rails.logger.debug "Remote IP: #{request.remote_ip}"
    # Access limited to Aria IP addresses
    # Aria IP address range: 64.238.195.110 to 64.238.195.125
    valid_ip=false
    begin
      if request.remote_ip =~ /\A(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})\z/
        if ($1 == "64") && ($2 == "238") && ($3 == "195") && ($4 >= "110" && $4 <= "125")
          valid_ip=true
        end
      end
    rescue Exception => e
      Rails.logger.error e
    end
    if !valid_ip
      request_http_basic_authentication
      return
    end
  end
end

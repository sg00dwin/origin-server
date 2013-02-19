require 'ipaddr'

class BillingController < BaseController

  skip_before_filter :authenticate
  before_filter :protect

  def protect
    Rails.logger.debug "Remote IP: #{request.remote_ip}"
    # Access limited to Aria IP address range
    valid_ip=false
    begin
      aria_config = Rails.application.config.billing[:aria][:config]
      ipaddr_low = IPAddr.new(aria_config[:event_remote_ipaddr_begin]).to_i
      ipaddr_high = IPAddr.new(aria_config[:event_remote_ipaddr_end]).to_i
      ipaddr_remote = IPAddr.new(request.remote_ip).to_i
      valid_ip = ((ipaddr_low..ipaddr_high) === ipaddr_remote)
    rescue Exception => e
      Rails.logger.error e
    end
    if !valid_ip
      request_http_basic_authentication
      return
    end
  end
end

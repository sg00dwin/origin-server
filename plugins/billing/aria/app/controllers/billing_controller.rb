require 'ipaddr'

class BillingController < BaseController
 
  skip_before_filter :authenticate_user!
  before_filter :protect

  def protect
    Rails.logger.debug "Remote IP: #{request.remote_ip}"
    # Access limited to Aria IP address range
    valid_ip=false
    begin
      aria_config = Rails.application.config.billing[:config]
      if (params[:auth_key] == aria_config[:auth_key]) and
         (params[:client_no].to_i == aria_config[:client_no])
        valid_ip = check_ip_validity(request.remote_ip)
      end
    rescue Exception => e
      Rails.logger.error e
    end
    if !valid_ip
      request_http_basic_authentication
      return
    end
  end

  private

  def check_ip_validity(remote_ip_str)
    aria_config = Rails.application.config.billing[:config]
    ip_remote = IPAddr.new(remote_ip_str).to_i

    ip_ranges = Rails.cache.fetch("aria_valid_ips", :expires_in => 1.hour) do
      ip_ranges = []
      aria_config[:event_remote_ipaddrs].split(',').each do |ir|
        ip_range = []
        ir.split(':').each { |ip| ip_range << IPAddr.new(ip.strip).to_i }
        ip_ranges << ip_range
      end
      ip_ranges
    end

    valid = false
    ip_ranges.each do |ip_range|
      if ip_range.size == 2
        valid = ((ip_range[0]..ip_range[1]) === ip_remote)
      elsif ip_range.size == 1
        valid = (ip_range[0] == ip_remote)
      else
        raise Exception.new "Invalid event_remote_ipaddrs aria configuration: #{aria_config[:event_remote_ipaddrs]}"
      end
      return true if valid
    end
    return false
  end
end

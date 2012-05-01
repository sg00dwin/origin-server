require 'rubygems'
require 'stickshift-controller'
require 'uplift-dynect-plugin'

module DnsHelper
  #
  # Utility functions for checking namespace availability and removing dns entries
  #

  $dns_con = nil
  
  def dns_service
    if not $dns_con
      $dns_con = Uplift::DynectPlugin.new({:end_point => "https://api2.dynect.net", 
                                           :customer_name => "demo-redhat",
                                           :user_name => "dev-rhcloud-user", 
                                           :password => "vo8zaijoN7Aecoo", 
                                           :domain_suffix => $domain, 
                                           :zone => "rhcloud.com", 
                                           :log_file => "/dev/null"})
    end
    $dns_con
  end

  def namespace_available?(namespace)
    return dns_service.namespace_available?(namespace)
  end

  def remove_dns_entries(entries=[])
    entries.each do |domain|
      yes = dns_service.namespace_available?(domain)
      if !yes
        #puts "deregistering #{domain}"
        dns_service.deregister_namespace(domain)
      end
    end
    dns_service.publish
    dns_service.close
  end

end
World(DnsHelper)

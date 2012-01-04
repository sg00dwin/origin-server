require 'resolv'

module OpenShift
  module Util
    
    # Invalid chars (") ($) (^) (<) (>) (|) (%) (/) (;) (:) (,) (\) (*) (=) (~)
    def self.check_rhlogin(rhlogin)
      if rhlogin =~ /["\$\^<>\|%\/;:,\\\*=~]/
        return false
      else
        return true
      end
    end
    
    def self.has_dns_txt?(namespace, domain="dev.rhcloud.com")
      dns = Resolv::DNS.new
      resp = dns.getresources("#{namespace}.#{domain}", Resolv::DNS::Resource::IN::TXT)
      return resp.length > 0
    end

  end
end

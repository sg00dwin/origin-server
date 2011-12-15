require 'resolv'
require 'pp'

module OpenShift
  class Server

    #
    # Get a DNS txt entry
    #
    def self.has_dns_txt?(namespace)
      dns = Resolv::DNS.new
      resp = dns.getresources("#{namespace}.#{OpenShift.c[:libra_domain]}", Resolv::DNS::Resource::IN::TXT)
      return resp.length > 0
    end
  end
end

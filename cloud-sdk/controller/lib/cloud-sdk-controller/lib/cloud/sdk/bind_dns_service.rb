#
# Make Openshift updates to a BIND DNS service
#
require 'rubygems'
require 'dnsruby'

module Cloud
  module Sdk

    class BindDnsService < DnsService
      @dns_provider = Cloud::Sdk::BindDnsService
  
      # DEPENDENCIES
      # Rails.application.config.cdk[:domain_suffix]
        
      # Rails.application.config.dns[:zone]
  
      # Rails.application.config.dns[:bind_server]
      # Rails.application.config.dns[:bind_port]
      # Rails.application.config.dns[:bind_keyname]
      # Rails.application.config.dns[:bind_keyvalue]
  
      attr_reader :server, :port, :keyname, :keyvalue
  
      def initialize(access_info = nil)
        if access_info != nil
          @server = access_info[:server]
          @port = access_info[:port].to_i
          @keyname = access_info[:keyname]
          @keyvalue = access_info[:keyvalue]
  
          @zone = access_info[:zone]
          @domain_suffix = access_info[:domain_suffix]
        elsif defined? Rails
          # extract from Rails.application.config[dns,cdk]
          rails_config = Rails.application.config
          @server = rails_config.dns[:bind_server]
          @port = rails_config.dns[:port].to_i
          @keyname = rails_config.dns[:keyname]
          @keyvalue = rails_config.dns[:keyvalue]
  
          @zone = rails_config.dns[:zone]
          @domain_suffix = rails_config.cdk[:domain_suffix]
        end
      end
  
      def namespace_available?(namespace)
        fqdn = "#{namespace}.#{@domain_suffix}"
  
        dns = Dnsruby::Resolver.new(:nameserver => @server, :port => @port)
  
        # If we get a response, then the namespace is reserved
        # An exception means that it is available
        begin
          dns.query(fqdn, Dnsruby::Types::TXT)
          return false
        rescue Dnsruby::NXDomain
          return true
        end
      end
  
      def register_namespace(namespace)
        # create a TXT record for the namespace in the domain
        fqdn = "#{namespace}.#{@domain_suffix}"
        dns = Dnsruby::Resolver.new(:nameserver => @server, :port => @port)
        # enable updates with key
        dns.tsig = @keyname, @keyvalue
  
        update = Dnsruby::Update.new(@zone)
        #   update.absent(fqdn, 'TXT')
        update.add(fqdn, 'TXT', 60, "Text record for #{namespace}")
        dns.send_message(update)
      end
  
      def deregister_namespace(namespace)
        # create a TXT record for the namespace in the domain
        fqdn = "#{namespace}.#{@domain_suffix}"
        dns = Dnsruby::Resolver.new(:nameserver => @server, :port => @port)
        # enable updates with key
        dns.tsig = @keyname, @keyvalue
  
        update = Dnsruby::Update.new(@zone)
        update.delete(fqdn, 'TXT')
        dns.send_message(update)
      end
  
      def register_application(app_name, namespace, public_hostname)
        # create an A record for the application in the domain
        fqdn = "#{app_name}-#{namespace}.#{@domain_suffix}"
        dns = Dnsruby::Resolver.new(:nameserver => @server, :port => @port)
        # enable updates with key
        dns.tsig = @keyname, @keyvalue
  
        update = Dnsruby::Update.new(@zone)
        update.add(fqdn, 'CNAME', 60, public_hostname)
        dns.send_message(update)
      end
  
      def deregister_application(app_name, namespace)
        # delete the CNAME record for the application in the domain
        fqdn = "#{app_name}-#{namespace}.#{@domain_suffix}"
        dns = Dnsruby::Resolver.new(:nameserver => @server, :port => @port)
  
        # We know we only have one CNAME per app, so look it up
        # We need it for the delete
        # should be an error if there's not exactly one answer
        current = dns.query(fqdn, 'CNAME')
        cnamevalue = current.answer[0].rdata.to_s        
  
        # enable updates with key
        dns.tsig = @keyname, @keyvalue
        update = Dnsruby::Update.new(@zone)
        update_response = update.delete(fqdn, 'CNAME', cnamevalue)
        send_response = dns.send_message(update)
      end
  
      def publish
      end
  
      def close
      end
      
    end
    
  end # SDK
end

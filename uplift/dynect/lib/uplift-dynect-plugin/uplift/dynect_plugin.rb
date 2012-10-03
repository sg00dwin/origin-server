require 'rubygems'
require 'resolv'
require 'uri'
require 'logger'
require 'net/https'
require 'json'

##
# This gem is an Uplift plugin for the Dynect DNS Service.
# The plugin works with the StickShift controller in order
# to maintain DNS records for user domains and applications.
# 
# This plugin requires the following config entries to be present:
# * dns[:dynect_url]            - The dynect API url
# * dns[:dynect_user_name]      - The API user
# * dns[:dynect_password]       - The API user password
# * dns[:dynect_customer_name]  - The API customer name
# * dns[:zone]                  - The DNS Zone
# * dns[:domain_suffix]         - The domain suffix for applications
module Uplift
  class DynectPlugin
    @@dyn_retries = 2      
    def initialize(args=nil)
      if not args.nil?      
        @end_point = args[:end_point]
        @customer_name = args[:customer_name]
        @user_name = args[:user_name]
        @password = args[:password]
        @domain_suffix = args[:domain_suffix]
        @zone = args[:zone]
        @@dyn_retries = args[:retries] || 1
        @@log_file = args[:log_file] || STDOUT
      elsif defined?Rails
        @end_point = Rails.configuration.dns[:dynect_url]
        @customer_name = Rails.configuration.dns[:dynect_customer_name]
        @user_name = Rails.configuration.dns[:dynect_user_name]
        @password = Rails.configuration.dns[:dynect_password]
        @domain_suffix = Rails.configuration.ss[:domain_suffix]
        @zone = Rails.configuration.dns[:zone]
      else
        raise Exception.new("Dynect DNS service is not initialized")
      end
      login
    end
    
    def logger
      if defined?(Rails.logger)
        Rails.logger
      else
        logger = Logger.new(@@log_file)
      end
    end
    
    def namespace_available?(namespace)
      login
      has_txt_record = dyn_has_txt_record?(namespace, @auth_token)
      return !has_txt_record
    end
    
    def register_namespace(namespace)
      login
      dyn_create_txt_record(namespace, @auth_token, @@dyn_retries)
    end
    
    def deregister_namespace(namespace)
      login
      dyn_delete_txt_record(namespace, @auth_token, @@dyn_retries)
    end
    
    def register_application(app_name, namespace, public_hostname)
      login
      create_app_dns_entries(app_name, namespace, public_hostname, @auth_token, @@dyn_retries)
    end
    
    def deregister_application(app_name, namespace)
      login
      delete_app_dns_entries(app_name, namespace, @auth_token, @@dyn_retries)    
    end
    
    def modify_application(app_name, namespace, public_hostname)
      login
      modify_app_dns_entries(app_name, namespace, public_hostname, @auth_token, @@dyn_retries)
    end
    
    def publish
      dyn_publish(@auth_token, @@dyn_retries)
    end
    
    def close
      dyn_logout(@auth_token, @@dyn_retries)
      @auth_token = nil
    end
    
    private
    
    def login
      if @auth_token
        return @auth_token
      else
        @auth_token = dyn_login(@@dyn_retries) 
        return @auth_token
      end
    end
    
    #
    # Get a DNS txt entry
    #
    def self.has_dns_txt?(namespace)
      dns = Resolv::DNS.new
      resp = nil
      begin
        resp = dns.getresources("#{namespace}.#{@domain_suffix}", Resolv::DNS::Resource::IN::TXT)
      rescue Exception => e
        raise_dns_exception(e)
      end
      return resp && resp.length > 0
    end
  
    def dyn_login(retries=0)
      # Set your customer name, username, and password on the command line
      # Set up our HTTP object with the required host and path
      url = URI.parse("#{@end_point}/REST/Session/")
      headers = { "Content-Type" => 'application/json' }
      # Login and get an authentication token that will be used for all subsequent requests.
      session_data = { :customer_name => @customer_name, :user_name => @user_name, :password => @password }

      auth_token = nil
      dyn_do('dyn_login', retries) do
        http = Net::HTTP.new(url.host, url.port)
        # below line get rid of the warning message
        # warning: peer certificate won't be verified in this SSL session
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        #http.set_debug_output $stderr
        http.use_ssl = true
        begin
          logger.debug "DEBUG: DYNECT Login with path: #{url.path}"
          resp, data = http.post(url.path, JSON.generate(session_data), headers)
          case resp
          when Net::HTTPSuccess
            raise_dns_exception(nil, resp) unless dyn_success?(data)
            result = JSON.parse(data)
            auth_token = result['data']['token']    
          else
            raise_dns_exception(nil, resp)
          end
        rescue StickShift::DNSException => e
          raise
        rescue Exception => e
          raise_dns_exception(e)
        end
      end
      # Is the session still alive?
      #headers = { "Content-Type" => 'application/json', 'Auth-Token' => auth_token }
      #resp, data = http.get(url.path, headers)
      #logger.debug 'GET Session Response: ', data, '\n'
      return auth_token
    end
  
    def raise_dns_exception(e=nil, resp=nil)
      if e
        logger.debug "DEBUG: Exception caught from DNS request: #{e.message}"
        logger.debug e.backtrace
      end
      if resp
        logger.debug "DEBUG: Response code: #{resp.code}"
        logger.debug "DEBUG: Response body: #{resp.body}"
      end
      raise StickShift::DNSException.new(145), "Error communicating with DNS system.  If the problem persists please contact Red Hat support."
    end
    
    def delete_app_dns_entries(app_name, namespace, auth_token, retries=2)
      dyn_delete_cname_record(app_name, namespace, auth_token, retries)
    end
  
    def create_app_dns_entries(app_name, namespace, public_hostname, auth_token, retries=2)
      dyn_create_cname_record(app_name, namespace, public_hostname, auth_token, retries)
    end
    
    def modify_app_dns_entries(app_name, namespace, public_hostname, auth_token, retries=2)
      dyn_modify_cname_record(app_name, namespace, public_hostname, auth_token, retries)
    end

    def dyn_do(method, retries=2)
      i = 0
      while true
        begin
          yield
          break
        rescue  StickShift::DNSException => e
          raise if i >= retries
          logger.debug "DEBUG: Retrying #{method} after exception caught from DNS request: #{e.message}"
          i += 1
        end
      end
    end
  
    def dyn_logout(auth_token, retries=0)
      # Logout
      resp, data = dyn_delete("Session/", auth_token, retries)
    end
    
    def dyn_create_cname_record(application, namespace, public_hostname, auth_token, retries=0)
      logger.debug "DEBUG: Public ip being configured '#{public_hostname}' to app '#{application}'"
      fqdn = "#{application}-#{namespace}.#{@domain_suffix}"
      # Create the CNAME record
      path = "CNAMERecord/#{@zone}/#{fqdn}/"
      record_data = { :rdata => { :cname => public_hostname }, :ttl => "60" }
      resp, data = dyn_post(path, record_data, auth_token, retries)
    end

    def dyn_modify_cname_record(application, namespace, public_hostname, auth_token, retries=0)
      logger.debug "DEBUG: Public ip being modified '#{public_hostname}' to app '#{application}'"
      fqdn = "#{application}-#{namespace}.#{@domain_suffix}"
      # MOdify the CNAME record
      path = "CNAMERecord/#{@zone}/#{fqdn}/"
      record_data = { :rdata => { :cname => public_hostname }, :ttl => "60" }
      resp, data = dyn_put(path, record_data, auth_token, retries)
    end
    
    def dyn_delete_cname_record(application, namespace, auth_token, retries=0)
      fqdn = "#{application}-#{namespace}.#{@domain_suffix}"
      # Delete the A record
      path = "CNAMERecord/#{@zone}/#{fqdn}/"
      resp, data = dyn_delete(path, auth_token, retries)
    end
    
    def dyn_delete_sshfp_record(application, namespace, auth_token, retries=0)
      fqdn = "#{application}-#{namespace}.#{@domain_suffix}"
      # Delete the SSHFP record
      path = "SSHFPRecord/#{@zone}/#{fqdn}/"
      resp, data = dyn_delete(path, auth_token, retries)
    end
  
    def dyn_create_txt_record(namespace, auth_token, retries=0)
      fqdn = "#{namespace}.#{@domain_suffix}"
      # Create the TXT record
      path = "TXTRecord/#{@zone}/#{fqdn}/"
      record_data = { :rdata => { :txtdata => "Text record for #{namespace}"}, :ttl => "60" }
      resp, data = dyn_post(path, record_data, auth_token, retries)
    end
  
    def dyn_delete_txt_record(namespace, auth_token, retries=0)
      fqdn = "#{namespace}.#{@domain_suffix}"
      # Delete the TXT record
      path = "TXTRecord/#{@zone}/#{fqdn}/"
      resp, data = dyn_delete(path, auth_token, retries)
    end
  
    def dyn_publish(auth_token, retries=0)
      # Publish the changes
      path = "Zone/#{@zone}/"
      publish_data = { "publish" => "true" }
      resp, data = dyn_put(path, publish_data, auth_token, retries)
    end
  
    def dyn_has_txt_record?(namespace, auth_token, raise_exception_on_exists=false)
      fqdn = "#{namespace}.#{@domain_suffix}"
      path = "TXTRecord/#{@zone}/#{fqdn}/"      
      dyn_has = dyn_has?(path, auth_token)
      if dyn_has && raise_exception_on_exists
        raise UserException.new(103), "A namespace with name '#{namespace}' already exists"
      else
        return dyn_has
      end
    end
    
    def handle_temp_redirect(resp, auth_token)
      if resp.body =~ /^\/REST\//
        headers = { "Content-Type" => 'application/json', 'Auth-Token' => auth_token }
        url = URI.parse("#{@end_point}#{resp.body}")
        http = Net::HTTP.new(url.host, url.port)
        # below line get rid of the warning message
        # warning: peer certificate won't be verified in this SSL session
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        #http.set_debug_output $stderr
        http.use_ssl = true
        sleep_time = 2
        success = false
        retries = 0
        while !success && retries < 5
          retries += 1
          begin
            logheaders = headers.clone
            logheaders["Auth-Token"]="[hidden]"
            logger.debug "DEBUG: DYNECT handle temp redirect with path: #{url.path} and headers: #{logheaders.inspect} attempt: #{retries} sleep_time: #{sleep_time}"
            resp, data = http.get(url.path, headers)
            case resp
            when Net::HTTPSuccess, Net::HTTPTemporaryRedirect
              data = JSON.parse(data)
              if data && data['status']
                logger.debug "DEBUG: DYNECT Response data: #{data['data']}"
                status = data['status']
                if status == 'success'
                  success = true
                elsif status == 'incomplete'
                  sleep sleep_time
                  sleep_time *= 2
                else #if status == 'failure'
                  logger.debug "DEBUG: DYNECT Response status: #{data['status']}"
                  raise_dns_exception(nil, resp)
                end
              end
            when Net::HTTPNotFound
              raise DNSNotFoundException.new(145), "Error communicating with DNS system.  Job returned not found"
            else
              raise_dns_exception(nil, resp)
            end
          rescue StickShift::DNSException => e
            raise
          rescue Exception => e
            raise_dns_exception(e)
          end
        end
        if !success
          raise_dns_exception(nil, resp)
        end
      else
        raise_dns_exception(nil, resp)
      end
    end
  
    def dyn_has?(path, auth_token, retries=2)
      headers = { "Content-Type" => 'application/json', 'Auth-Token' => auth_token }
      url = URI.parse("#{@end_point}/REST/#{path}")
      has = false
      dyn_do('dyn_has?', retries) do
        http = Net::HTTP.new(url.host, url.port)
        # below line get rid of the warning message
        # warning: peer certificate won't be verified in this SSL session
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        #http.set_debug_output $stderr
        http.use_ssl = true
        begin
          logheaders = headers.clone
          logheaders["Auth-Token"]="[hidden]"
          logger.debug "DEBUG: DYNECT has? with path: #{url.path} and headers: #{logheaders.inspect}"
          resp, data = http.get(url.path, headers)
          case resp
          when Net::HTTPSuccess
            has = dyn_success?(data)
          when Net::HTTPNotFound
            logger.debug "DEBUG: DYNECT returned 404 for: #{url.path}"
          when Net::HTTPTemporaryRedirect
            begin
              handle_temp_redirect(resp, auth_token)
              has = true
            rescue Exception => e
              has = false
            end
          else
            raise_dns_exception(nil, resp)
          end 
        rescue StickShift::DNSException => e
          raise
        rescue Exception => e
          raise_dns_exception(e)
        end
      end
      return has
    end
  
    def dyn_put(path, put_data, auth_token, retries=0)
      return dyn_put_post(path, put_data, auth_token, true, retries)
    end
  
    def dyn_post(path, post_data, auth_token, retries=0)
      return dyn_put_post(path, post_data, auth_token, false, retries)
    end
  
    def dyn_put_post(path, post_data, auth_token, put=false, retries=0)
      url = URI.parse("#{@end_point}/REST/#{path}")
      headers = { "Content-Type" => 'application/json', 'Auth-Token' => auth_token }
      resp, data = nil, nil
      dyn_do('dyn_put_post', retries) do
        http = Net::HTTP.new(url.host, url.port)
        # below line get rid of the warning message
        # warning: peer certificate won't be verified in this SSL session
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        #http.set_debug_output $stderr
        http.use_ssl = true
        json_data = JSON.generate(post_data);
        begin
          logheaders = headers.clone
          logheaders["Auth-Token"]="[hidden]"
          logger.debug "DEBUG: DYNECT put/post with path: #{url.path} json data: #{json_data} and headers: #{logheaders.inspect}"
          if put
            resp, data = http.put(url.path, json_data, headers)
          else
            resp, data = http.post(url.path, json_data, headers)
          end
          case resp
          when Net::HTTPSuccess
            raise_dns_exception(nil, resp) unless dyn_success?(data)
          when Net::HTTPTemporaryRedirect
            handle_temp_redirect(resp, auth_token)
          else
            raise_dns_exception(nil, resp)
          end
        rescue StickShift::DNSException => e
          raise
        rescue Exception => e
          raise_dns_exception(e)
        end
      end
      return resp, data
    end
    
    def dyn_success?(data)
      logger.debug "DEBUG: DYNECT Response: #{data}"
      success = false
      if data
        data = JSON.parse(data)
        if data && data['status'] && data['status'] == 'failure'
          logger.debug "DEBUG: DYNECT Response status: #{data['status']}"
        elsif data && data['status'] == 'success'
          logger.debug "DEBUG: DYNECT Response data: #{data['data']}"
          #has = data['data'][0].length > 0
          success = true
        end
      end
      success
    end
  
    def dyn_delete(path, auth_token, retries=0)
      headers = { "Content-Type" => 'application/json', 'Auth-Token' => auth_token }
      url = URI.parse("#{@end_point}/REST/#{path}")
      resp, data = nil, nil
      dyn_do('dyn_delete', retries) do
        http = Net::HTTP.new(url.host, url.port)
        # below line get rid of the warning message
        # warning: peer certificate won't be verified in this SSL session
        http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        #http.set_debug_output $stderr
        http.use_ssl = true
        begin
          logheaders = headers.clone
          logheaders["Auth-Token"]="[hidden]"
          logger.debug "DEBUG: DYNECT delete with path: #{url.path} and headers: #{logheaders.inspect}"
          resp, data = http.delete(url.path, headers)
          case resp
          when Net::HTTPSuccess
            raise_dns_exception(nil, resp) unless dyn_success?(data)
          when Net::HTTPNotFound
            logger.debug "DEBUG: DYNECT: Could not find #{url.path} to delete"
          when Net::HTTPTemporaryRedirect
            handle_temp_redirect(resp, auth_token)
          else
            raise_dns_exception(nil, resp)
          end
        rescue StickShift::DNSException => e
          raise
        rescue Exception => e
          raise_dns_exception(e)
        end
      end
      return resp, data
    end
  end
end

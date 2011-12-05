require 'resolv'

class DNSException < Cloud::Sdk::CdkException
  def initialize(msg=nil,code=nil)
    super(msg,code)
  end
end

class DNSNotFoundException < DNSException; 
  def initialize(msg=nil,code=nil)
    super(msg,code)
  end
end

class DnsService
  @@dyn_retries = 2
  
  def initialize
  end
  
  def namespace_available?(namespace)
    return has_dns_txt?(namespace)
  end
  
  def register_namespace(namespace)
    login
    DnsService.dyn_create_txt_record(namespace, @auth_token, @@dyn_retries)
  end
  
  def deregister_namespace(namespace)
    login
    DnsService.dyn_delete_txt_record(namespace, @auth_token, @@dyn_retries)
  end
  
  def register_application(app_name, namespace, user_name)
    login
    public_hostname = "" #TODO either need to retrieve this or pass it in.  retrieving means an inefficiency
    DnsService.create_app_dns_entries(app_name, namespace, public_hostname, @auth_token, @@dyn_retries)
  end
  
  def deregister_application(app_name, namespace, user_name)
    login
    DnsService.delete_app_dns_entries(app_name, namespace, @auth_token, @@dyn_retries)    
  end
  
  def publish
    DnsService.dyn_publish(@auth_token, @@dyn_retries)
  end
  
  def close
    DnsService.dyn_logout(@auth_token, @@dyn_retries)
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
    resp = dns.getresources("#{namespace}.#{Rails.application.config.cdk[:domain_suffix]}", Resolv::DNS::Resource::IN::TXT)
    return resp.length > 0
  end

  def self.dyn_login(retries=0)
    # Set your customer name, username, and password on the command line
    # Set up our HTTP object with the required host and path
    url = URI.parse("#{Rails.application.config.cdk[:dynect_url]}/REST/Session/")
    headers = { "Content-Type" => 'application/json' }
    # Login and get an authentication token that will be used for all subsequent requests.
    session_data = { :customer_name => Rails.application.config.cdk[:dynect_customer_name], :user_name => Rails.application.config.cdk[:dynect_user_name], :password => Rails.application.config.cdk[:dynect_password] }
    auth_token = nil
    dyn_do('dyn_login', retries) do
      http = Net::HTTP.new(url.host, url.port)
      #http.set_debug_output $stderr
      http.use_ssl = true
      begin
        Rails.logger.debug "DEBUG: DYNECT Login with path: #{url.path}"
        resp, data = http.post(url.path, JSON.generate(session_data), headers)
        case resp
        when Net::HTTPSuccess
          raise_dns_exception(nil, resp) unless dyn_success?(data)
          result = JSON.parse(data)
          auth_token = result['data']['token']         
        else
          raise_dns_exception(nil, resp)
        end
      rescue DNSException => e
        raise
      rescue Exception => e
        raise_dns_exception(e)
      end
    end
    # Is the session still alive?
    #headers = { "Content-Type" => 'application/json', 'Auth-Token' => auth_token }
    #resp, data = http.get(url.path, headers)
    #Rails.logger.debug 'GET Session Response: ', data, '\n'
    return auth_token
  end

  def self.raise_dns_exception(e=nil, resp=nil)
    if e
      Rails.logger.debug "DEBUG: Exception caught from DNS request: #{e.message}"
      Rails.logger.debug e.backtrace        
    end
    if resp
      Rails.logger.debug "DEBUG: Response code: #{resp.code}"
      Rails.logger.debug "DEBUG: Response body: #{resp.body}"
    end
    raise DNSException.new(145), "Error communicating with DNS system.  If the problem persists please contact Red Hat support.", caller[0..5]
  end
  
  def self.delete_app_dns_entries(app_name, namespace, auth_token, retries=2)
    dyn_delete_cname_record(app_name, namespace, auth_token, retries)
  end

  def self.create_app_dns_entries(app_name, namespace, public_hostname, auth_token, retries=2)
    dyn_create_cname_record(app_name, namespace, public_hostname, auth_token, retries)
  end

  def self.recreate_app_dns_entries(app_name, old_namespace, new_namespace, public_hostname, auth_token, retries=2)
    dyn_delete_cname_record(app_name, old_namespace, auth_token, retries)
    dyn_create_cname_record(app_name, new_namespace, public_hostname, auth_token, retries)
  end

  def self.dyn_do(method, retries=2)
    i = 0
    while true
      begin
        yield
        break
      rescue DNSException => e
        raise if i >= retries
        Rails.logger.debug "DEBUG: Retrying #{method} after exception caught from DNS request: #{e.message}"
        i += 1
      end
    end
  end

  def self.dyn_logout(auth_token, retries=0)
    # Logout
    resp, data = dyn_delete("Session/", auth_token, retries)
  end
  
  def self.dyn_create_cname_record(application, namespace, public_hostname, auth_token, retries=0)
    #public_hostname = get_fact_direct('public_hostname')
    Rails.logger.debug "DEBUG: Public ip being configured '#{public_hostname}' to app '#{application}'"
    fqdn = "#{application}-#{namespace}.#{Rails.application.config.cdk[:domain_suffix]}"
    # Create the CNAME record
    path = "CNAMERecord/#{Rails.application.config.cdk[:zone]}/#{fqdn}/"
    record_data = { :rdata => { :cname => public_hostname }, :ttl => "60" }
    resp, data = dyn_post(path, record_data, auth_token, retries)
  end
  
  def self.dyn_delete_cname_record(application, namespace, auth_token, retries=0)
    fqdn = "#{application}-#{namespace}.#{Rails.application.config.cdk[:domain_suffix]}"
    # Delete the A record
    path = "CNAMERecord/#{Rails.application.config.cdk[:zone]}/#{fqdn}/"
    resp, data = dyn_delete(path, auth_token, retries)
  end
  
  def self.dyn_delete_sshfp_record(application, namespace, auth_token, retries=0)
    fqdn = "#{application}-#{namespace}.#{Rails.application.config.cdk[:domain_suffix]}"
    # Delete the SSHFP record
    path = "SSHFPRecord/#{Rails.application.config.cdk[:zone]}/#{fqdn}/"
    resp, data = dyn_delete(path, auth_token, retries)
  end

  def self.dyn_create_txt_record(namespace, auth_token, retries=0)
    fqdn = "#{namespace}.#{Rails.application.config.cdk[:domain_suffix]}"
    # Create the TXT record
    path = "TXTRecord/#{Rails.application.config.cdk[:zone]}/#{fqdn}/"
    record_data = { :rdata => { :txtdata => "Text record for #{namespace}"}, :ttl => "60" }
    resp, data = dyn_post(path, record_data, auth_token, retries)
  end

  def self.dyn_delete_txt_record(namespace, auth_token, retries=0)
    fqdn = "#{namespace}.#{Rails.application.config.cdk[:domain_suffix]}"
    # Delete the TXT record
    path = "TXTRecord/#{Rails.application.config.cdk[:zone]}/#{fqdn}/"
    resp, data = dyn_delete(path, auth_token, retries)
  end

  def self.dyn_publish(auth_token, retries=0)
    # Publish the changes
    path = "Zone/#{Rails.application.config.cdk[:zone]}/"
    publish_data = { "publish" => "true" }
    resp, data = dyn_put(path, publish_data, auth_token, retries)
  end

  def self.dyn_has_txt_record?(namespace, auth_token, raise_exception_on_exists=false)
    fqdn = "#{namespace}.#{Rails.application.config.cdk[:domain_suffix]}"
    path = "TXTRecord/#{Rails.application.config.cdk[:zone]}/#{fqdn}/"      
    dyn_has = dyn_has?(path, auth_token)
    if dyn_has && raise_exception_on_exists
      raise UserException.new(103), "A namespace with name '#{namespace}' already exists", caller[0..5]
    else
      return dyn_has
    end
  end
  
  def self.handle_temp_redirect(resp, auth_token)
    if resp.body =~ /^\/REST\//
      headers = { "Content-Type" => 'application/json', 'Auth-Token' => auth_token }
      url = URI.parse("#{Rails.application.config.cdk[:dynect_url]}#{resp.body}")
      http = Net::HTTP.new(url.host, url.port)
      #http.set_debug_output $stderr
      http.use_ssl = true
      sleep_time = 2
      success = false
      retries = 0
      while !success && retries < 5
        retries += 1
        begin
          Rails.logger.debug "DEBUG: DYNECT handle temp redirect with path: #{url.path} and headers: #{headers.pretty_inspect} attempt: #{retries} sleep_time: #{sleep_time}"
          resp, data = http.get(url.path, headers)
          case resp
          when Net::HTTPSuccess, Net::HTTPTemporaryRedirect
            data = JSON.parse(data)
            if data && data['status']
              Rails.logger.debug "DEBUG: DYNECT Response data: #{data['data']}"
              status = data['status']
              if status == 'success'
                success = true
              elsif status == 'incomplete'
                sleep sleep_time
                sleep_time *= 2
              else #if status == 'failure'
                Rails.logger.debug "DEBUG: DYNECT Response status: #{data['status']}"
                raise_dns_exception(nil, resp)
              end
            end
          when Net::HTTPNotFound
            raise DNSNotFoundException.new(145), "Error communicating with DNS system.  Job returned not found", caller[0..5]
          else
            raise_dns_exception(nil, resp)
          end
        rescue DNSException => e
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

  def self.dyn_has?(path, auth_token, retries=2)
    headers = { "Content-Type" => 'application/json', 'Auth-Token' => auth_token }
    url = URI.parse("#{Rails.application.config.cdk[:dynect_url]}/REST/#{path}")
    has = false
    dyn_do('dyn_has?', retries) do
      http = Net::HTTP.new(url.host, url.port)
      #http.set_debug_output $stderr
      http.use_ssl = true
      begin
        Rails.logger.debug "DEBUG: DYNECT has? with path: #{url.path} and headers: #{headers.pretty_inspect}"
        resp, data = http.get(url.path, headers)
        case resp
        when Net::HTTPSuccess
          has = dyn_success?(data)
        when Net::HTTPNotFound
          Rails.logger.debug "DEBUG: DYNECT returned 404 for: #{url.path}"
        when Net::HTTPTemporaryRedirect
          begin
            handle_temp_redirect(resp, auth_token)
            has = true
          rescue DNSNotFoundException => e
            has = false
          end
        else
          raise_dns_exception(nil, resp)
        end 
      rescue DNSException => e
        raise
      rescue Exception => e
        raise_dns_exception(e)
      end
    end
    return has
  end

  def self.dyn_put(path, put_data, auth_token, retries=0)
    return dyn_put_post(path, put_data, auth_token, true, retries)
  end

  def self.dyn_post(path, post_data, auth_token, retries=0)
    return dyn_put_post(path, post_data, auth_token, false, retries)
  end

  def self.dyn_put_post(path, post_data, auth_token, put=false, retries=0)
    url = URI.parse("#{Rails.application.config.cdk[:dynect_url]}/REST/#{path}")
    headers = { "Content-Type" => 'application/json', 'Auth-Token' => auth_token }
    resp, data = nil, nil
    dyn_do('dyn_put_post', retries) do
      http = Net::HTTP.new(url.host, url.port)
      #http.set_debug_output $stderr
      http.use_ssl = true
      json_data = JSON.generate(post_data);
      begin
        Rails.logger.debug "DEBUG: DYNECT put/post with path: #{url.path} json data: #{json_data} and headers: #{headers.pretty_inspect}"
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
      rescue DNSException => e
        raise
      rescue Exception => e
        raise_dns_exception(e)
      end
    end
    return resp, data
  end
  
  def self.dyn_success?(data)
    Rails.logger.debug "DEBUG: DYNECT Response: #{data}"
    success = false
    if data
      data = JSON.parse(data)
      if data && data['status'] && data['status'] == 'failure'
        Rails.logger.debug "DEBUG: DYNECT Response status: #{data['status']}"
      elsif data && data['status'] == 'success'
        Rails.logger.debug "DEBUG: DYNECT Response data: #{data['data']}"
        #has = data['data'][0].length > 0
        success = true
      end
    end
    success
  end

  def self.dyn_delete(path, auth_token, retries=0)
    headers = { "Content-Type" => 'application/json', 'Auth-Token' => auth_token }
    url = URI.parse("#{Rails.application.config.cdk[:dynect_url]}/REST/#{path}")
    resp, data = nil, nil
    dyn_do('dyn_delete', retries) do
      http = Net::HTTP.new(url.host, url.port)
      #http.set_debug_output $stderr
      http.use_ssl = true
      begin
        Rails.logger.debug "DEBUG: DYNECT delete with path: #{url.path} and headers: #{headers.pretty_inspect}"
        resp, data = http.delete(url.path, headers)
        case resp
        when Net::HTTPSuccess
          raise_dns_exception(nil, resp) unless dyn_success?(data)
        when Net::HTTPNotFound
          Rails.logger.debug "DEBUG: DYNECT: Could not find #{url.path} to delete"
        when Net::HTTPTemporaryRedirect
          handle_temp_redirect(resp, auth_token)
        else
          raise_dns_exception(nil, resp)
        end
      rescue DNSException => e
        raise
      rescue Exception => e
        raise_dns_exception(e)
      end
    end
    return resp, data
  end
end
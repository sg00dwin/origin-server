require "rubygems"
require "uri"
require "net/http"
require "net/https"
require "json"
require "parseconfig"
  
module RHC  

  TYPES = { "php-5.3.2" => :php,
    "rack-1.1.0" => :rack,
    "wsgi-3.2.1" => :wsgi
  }
  
  def RHC.get_type_keys(sep)
    i = 1
    type_keys = ''
    TYPES.each_key do |key|
      type_keys += key
      if i < TYPES.size
        type_keys += sep
      end
        i += 1
    end
    type_keys
  end
  
  def RHC.check_rhlogin(rhlogin)
    if rhlogin =~ /([^@]+)@([a-zA-Z0-9\.])+\.([a-zA-Z]{2,3})/
      if $1 =~ /[^a-zA-Z0-9\.\-\+]/
        return false
      else
        return true
      end
    else
      return false
    end
  end
  
  def RHC.check_app(app)
    check_field(app, 'application')
  end
  
  def RHC.check_namespace(namespace)
    check_field(namespace, 'namespace')
  end
  
  def RHC.check_field(field, type)
    if field
      if field =~ /[^0-9a-zA-Z]/
        puts "#{type} contains non-alphanumeric characters!"
          return false
      end
    else
      puts "#{type} is required"
      return false
    end
    true
  end
  
  def RHC.get_type(type)
    if type   
      if !(RHC::TYPES.has_key?(type))        
        puts 'type must be ' << RHC::get_type_keys(' or ')
      else
        return RHC::TYPES[type]
      end
    else
      puts "Type is required"
    end
    nil
  end
    
  def RHC.get_user_info(li_server, rhlogin, net_http, debug)  
    
    puts "Contacting https://#{li_server}"
    json_data = JSON.generate(
                    {'rhlogin' => rhlogin})
    puts "DEBUG: Json string: #{json_data}" if debug
    
    url = URI.parse("https://#{li_server}/php/user_info.php")
    req = net_http::Post.new(url.path)
    
    req.set_form_data({'json_data' => json_data})
    http = net_http.new(url.host, url.port)
    if url.scheme == "https"
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    response = http.start {|http| http.request(req)}
    
    puts "DEBUG:" if debug
    p response if debug
    json_resp = JSON.parse(response.body);
    
    unless json_resp['return'].to_s.strip == "0"
        puts "Problem with server. Response code was #{response.code}"
        puts "HTTP response from server is #{response.body}"
        exit 255
    end
    
    if debug
        puts "HTTP response from server is #{response.body}"
    end
    user_info = JSON.parse(json_resp['stdout'].to_s)  
    user_info
  end
    
end
require "rubygems"
require 'fileutils'
require "getoptlong"
require "json"
require "net/http"
require "net/https"
require "parseconfig"
require 'resolv'
require "uri"

module RHC

  TYPES = { "php-5.3.2" => :php,
    "rack-1.1.0" => :rack,
    "wsgi-3.2.1" => :wsgi
  }

  def self.get_type_keys(sep)
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

  # Invalid chars (") ($) (^) (<) (>) (|) (%) (/) (;) (:) (,) (\) (*) (=) (~)
  def self.check_rhlogin(rhlogin)
    if rhlogin && rhlogin.length < 6
      puts 'RHLogin must be at least 6 characters'
      return false
    elsif rhlogin =~ /["\$\^<>\|%\/;:,\\\*=~]/
      puts 'RHLogin may not contain any of these characters: (\") ($) (^) (<) (>) (|) (%) (/) (;) (:) (,) (\) (*) (=) (~)'
      return false
    else
      return true
    end
  end

  def self.check_app(app)
    check_field(app, 'application')
  end

  def self.check_namespace(namespace)
    check_field(namespace, 'namespace')
  end

  def self.check_field(field, type)
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

  def self.get_type(type)
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

  def self.print_post_data(h, debug)
    if (debug)
      puts 'DEBUG: Submitting form:'
      h.each do |k,v|
        if k.to_s != 'password'
          puts "#{k.to_s}: #{v.to_s}"
        else
          print 'password: '
          for i in (1..v.length)
            print 'X'
          end
          puts ''
        end
      end
    end
  end

  def self.get_user_info(libra_server, rhlogin, password, net_http, debug, print_result)

    puts "Contacting https://#{libra_server}"
    data = {'rhlogin' => rhlogin, 'password' => password}
    if debug
      data['debug'] = "true"
    end
    print_post_data(data, debug)
    json_data = JSON.generate(data)

    url = URI.parse("https://#{libra_server}/app/broker/userinfo")
    response = http_post(net_http, url, json_data)

    unless response.code == '200'
        if response.code == '404'
          puts "A user with rhlogin '#{rhlogin}' does not have a registered domain.  Be sure to run rhc-create-domain before using the other rhc tools."
        elsif response.code == '401'
          puts "Invalid user credentials"
        else
          print_response_err(response, debug)
        end
        exit 254
    end
    if print_result
      print_response_success(response, debug)
    end
    json_resp = JSON.parse(response.body)
    user_info = JSON.parse(json_resp['result'].to_s)
    user_info
  end

  def self.get_password
    password = nil
    begin
      print "Password: "
      system "stty -echo"
      password = gets.chomp
    ensure
      system "stty echo"
    end
    puts "\n"
    password
  end

  def self.http_post(http, url, json_data)
    req = http::Post.new(url.path)

    req.set_form_data({'json_data' => json_data})
    http = http.new(url.host, url.port)
    if url.scheme == "https"
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    response = http.start {|http| http.request(req)}
    if response.code == '404' && response.content_type == 'text/html'
      # TODO probably want to remove this at some point
      puts "!!!! WARNING !!!! WARNING !!!! WARNING !!!!"
      puts "RHCloud server not found.  You might want to try updating your rhc client tools."
      exit 218
    end
    response
  end

  def self.print_response_err(response, debug)
    puts "Problem reported from server. Response code was #{response.code}."
    if (!debug)
      puts "Re-run with -d for more information."
    end
    exit_code = 254
    if response.content_type == 'application/json'
      exit_code = print_json_body(response, debug)
    elsif debug
      puts "HTTP response from server is #{response.body}"
    end
    exit exit_code
  end

  def self.print_response_success(response, debug)
    if debug
      puts "HTTP response from server is:"
      print_json_body(response, debug)
    end
  end

  def self.print_json_body(response, debug)
    json_resp = JSON.parse(response.body);
    exit_code = json_resp['exit_code']
    if debug
      if json_resp['debug']
        puts ''
        puts 'DEBUG:'
        puts json_resp['debug']
        puts ''
        puts "Exit Code: #{exit_code}"
        if (json_resp.length > 3)
          json_resp.each do |k,v|
            if (k != 'results' && k != 'debug' && k != 'exit_code')
              puts "#{k.to_s}: #{v.to_s}"
            end
          end
        end
      end
    end
    if json_resp['result']
      puts ''
      puts 'RESULT:'
      puts json_resp['result']
      puts ''
    end
    exit_code
  end

end

#
# Config paths... /etc/libra/libra.conf or $GEM/conf/libra.conf -> ~/.li/libra.conf
#
linux_cfg = '/etc/libra/libra.conf'
gem_cfg = File.join(File.expand_path(File.dirname(__FILE__) + "/../conf"), 'libra.conf')
@config_path = File.exists?(linux_cfg) ? linux_cfg : gem_cfg
if File.exists?("#{ENV['HOME']}/.li")
    if !File.directory?("#{ENV['HOME']}/.li")
        print "Moving old-style config file..."
        FileUtils.mv "#{ENV['HOME']}/.li", "#{ENV['HOME']}/.li.bak"
        FileUtils.mkdir_p "#{ENV['HOME']}/.li"
        FileUtils.mv "#{ENV['HOME']}/.li.bak", "#{ENV['HOME']}/.li/libra.conf"
        puts " Done."
    end
else
    FileUtils.mkdir_p "#{ENV['HOME']}/.li"
end
@local_config_path = "#{ENV['HOME']}/.li/libra.conf"

FileUtils.touch @local_config_path

begin
    @global_config = ParseConfig.new(@config_path)
    @local_config = ParseConfig.new(@local_config_path)
rescue Errno::EACCES => e
    puts "Could not open config file: #{e.message}"
    exit 253
end

#
# Check for proxy environment
#
if ENV['http_proxy']
    host, port = ENV['http_proxy'].split(':')
    @http = Net::HTTP::Proxy(host, port)
else
    @http = Net::HTTP
end

#
# Check for local var in ~/.li/libra.conf use it, else use /etc/libra/libra.conf
#
def get_var(var)
    @local_config.get_value(var) ? @local_config.get_value(var) : @global_config.get_value(var)
end


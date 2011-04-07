# Copyright 2010 Red Hat, Inc.
#
# Permission is hereby granted, free of charge, to any person
# obtaining a copy of this software and associated documentation files
# (the "Software"), to deal in the Software without restriction,
# including without limitation the rights to use, copy, modify, merge,
# publish, distribute, sublicense, and/or sell copies of the Software,
# and to permit persons to whom the Software is furnished to do so,
# subject to the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT.  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS
# BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN
# ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
# CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

require 'rubygems'
require 'fileutils'
require 'getoptlong'
require 'json'
require 'net/http'
require 'net/https'
require 'parseconfig'
require 'resolv'
require 'uri'


module RHC

  Maxdlen = 16
  
  TYPES = { 'php-5.3.2' => :php,
    'rack-1.1.0' => :rack,
    'wsgi-3.2.1' => :wsgi
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
    check_field(app, 'application', Maxdlen)
  end
  
  def self.check_namespace(namespace)
    check_field(namespace, 'namespace', Maxdlen)
  end
  
  def self.check_field(field, type, max=0)
    if field
      if field =~ /[^0-9a-zA-Z]/
        puts "#{type} contains non-alphanumeric characters!"
        return false
      end
      if max != 0 && field.length > Maxdlen
        puts "maximum #{type} size is #{Maxdlen} characters"
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
    data = {'rhlogin' => rhlogin}
    if debug
      data['debug'] = "true"
    end
    print_post_data(data, debug)
    json_data = JSON.generate(data)
    
    url = URI.parse("https://#{libra_server}/app/broker/userinfo")
    response = http_post(net_http, url, json_data, password)
    
    unless response.code == '200'
      if response.code == '404'
        puts "A user with rhlogin '#{rhlogin}' does not have a registered domain.  Be sure to run rhc-create-domain before using the other rhc tools."
        exit 99
      elsif response.code == '401'
        puts "Invalid user credentials"
        exit 97
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
  
  def self.http_post(http, url, json_data, password)
    req = http::Post.new(url.path)
    
    req.set_form_data({'json_data' => json_data, 'password' => password})
    http = http.new(url.host, url.port)
    if url.scheme == "https"
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    begin
      response = http.start {|http| http.request(req)}
      if response.code == '404' && response.content_type == 'text/html'
        # TODO probably want to remove this at some point
        puts "!!!! WARNING !!!! WARNING !!!! WARNING !!!!"
        puts "RHCloud server not found.  You might want to try updating your rhc client tools."
        exit 218
      end
      response
    rescue Exception => e
      puts "There was a problem communicating with the server. Response message: #{e.message}"
      puts "If you were disconnected it is possible the operation finished without being able to report success."  
      puts "You can use rhc-user-info and rhc-ctl-app to learn about the status of your user and application(s)."
      exit 219
    end
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
    exit exit_code.nil? ? 666 : exit_code
  end
  
  def self.print_response_success(response, debug, always_print_result=false)
    if debug
      puts "Response from server:"
      print_json_body(response, debug)
    elsif always_print_result
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
# Config paths... /etc/openshift/express.conf or $GEM/conf/express.conf -> ~/.openshift/express.conf
#
# semi-private: Just in case we rename again :)
_conf_name = 'express.conf'
_linux_cfg = '/etc/openshift/' + _conf_name
_gem_cfg = File.join(File.expand_path(File.dirname(__FILE__) + "/../conf"), _conf_name)
_home_conf = "#{ENV['HOME']}/.openshift"
@local_config_path = _home_conf + "/" + _conf_name

@config_path = File.exists?(_linux_cfg) ? _linux_cfg : _gem_cfg

FileUtils.mkdir_p _home_conf unless File.directory?(_home_conf)
if !File.exists?(@local_config_path) && File.exists?("#{ENV['HOME']}/.li/libra.conf")
    print "Moving old-style config file..."
    FileUtils.cp "#{ENV['HOME']}/.li/libra.conf", @local_config_path
    FileUtils.mv "#{ENV['HOME']}/.li/libra.conf", "#{ENV['HOME']}/.li/libra.conf.deprecated"
    puts " Done."
 end

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
# Check for local var in ~/.li/libra.conf use it, else use $GEM/../conf/libra.conf
#
def get_var(var)
  @local_config.get_value(var) ? @local_config.get_value(var) : @global_config.get_value(var)
end

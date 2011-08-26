#!/usr/bin/ruby

require 'rubygems'
require 'net/http'
require 'net/https'
require 'resolv'
require 'json'


API = "1.1.1"
@libra_server = 'localhost'
@password = ' '
@rhlogin = 'mmcgrath3@redhat.com'

#
# Check for proxy environment
#
if ENV['http_proxy']
  host, port = ENV['http_proxy'].split(':')
  @http = Net::HTTP::Proxy(host, port)
else
  @http = Net::HTTP
end

def post_json(uri, data)
    json_data = JSON.generate(data)
    url = URI.parse("https://#{@libra_server}#{uri}")
    puts "  Contacting URL: https://#{@libra_server}#{uri}" if @debug
    puts "  json_data: #{json_data}" if @debug
    req = @http::Post.new(url.path)
    req.set_form_data({'json_data' => json_data, 'password' => @password})
    http = @http.new(url.host, url.port)
    http.open_timeout = 10
    if url.scheme == "https"
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    begin
        response = http.start {|http| http.request(req)}
    rescue Exception => e
        puts "  ERROR: #{e.message}"
        return nil
    end
    return response
end

def create_new()
    
    data = {
        :cartridge => 'php-5.3',
        :action => 'configure',
        :app_name => 'jenkslave',
        :rhlogin => 'mmcgrath3@redhat.com'
      }
    
    
    response = post_json("/broker/cartridge", data)
    
    if response.code == '200'
        json_resp = JSON.parse(response.body)
        json_data = JSON.parse(json_resp['data'])
        health_check_path = json_data['health_check_path']
    else
        puts response
    end
    
    if @user_info['app_info']['jenkslave']
        uuid = @user_info['app_info']['jenkslave']['uuid']
        return uuid
    end
end
def get_uuid()
    data = {'rhlogin' => @rhlogin}
    response = post_json("/broker/userinfo", data)
    
    if response.code == '200'
        body = JSON.parse(response.body)
        @user_info = JSON.parse(body['data'].to_s)
    else
        puts "Failed to get user info: #{response.code}"
        puts "Reason: #{response.message} - #{response.body}"
    end
    
    if @user_info['app_info']['jenkslave']
        uuid = @user_info['app_info']['jenkslave']['uuid']
        return uuid
    else
        return nil
    end
end

uuid = get_uuid()

if uuid
    $stderr.puts "Jenkins slave is already running"
    puts uuid
else
    $stderr.puts "jenkins slave does not exist, creating"
    create_new()
    uuid = get_uuid()
    puts uuid
end

#rhc-create-app -n -a jenkslave -t php-5.3 -p ' ' -l mmcgrath3@redhat.com
#ssh -i ~/jenk/data/id_rsa -o "StrictHostKeyChecking=no" 34f87f0dc4d644d69546b57164675588@jenkslave-mmcgrath3.dev.rhcloud.com 'mkdir -p ./jenkslave/data/jenkins && cd ./jenkslave/data/jenkins && wget http://jenk-mmcgrath3.dev.rhcloud.com/jnlpJars/slave.jar && java -jar slave.jar'

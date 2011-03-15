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

  def RHC.print_post_data(h, debug)
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

  def RHC.get_user_info(li_server, rhlogin, password, net_http, debug)

    puts "Contacting https://#{li_server}"
    data = {'rhlogin' => rhlogin, 'password' => password}
    print_post_data(data, debug)
    json_data = JSON.generate(data)

    url = URI.parse("https://#{li_server}/php/user_info.php")
    response = http_post(net_http, url, json_data)

    puts "DEBUG:" if debug
    p response if debug
    json_resp = JSON.parse(response.body)

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

  def RHC.get_password
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

  def RHC.http_post(http, url, json_data)
    req = http::Post.new(url.path)

    req.set_form_data({'json_data' => json_data})
    http = http.new(url.host, url.port)
    if url.scheme == "https"
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    response = http.start {|http| http.request(req)}
    response
  end

end

#
# Config paths... /etc/libra/client.conf -> ./client.conf -> ~/.li/client.conf
#
@config_path = File.exists?('client.conf') ? 'client.conf' : '/etc/libra/client.conf'
@local_config_path = "#{ENV['HOME']}/.li/client.conf"
@legacy_config_path = "#{ENV['HOME']}/.li"

unless File.directory?(@legacy_config_path)
  puts "Backing up old config file at ~/.li"
  FileUtils.mv @legacy_config_path, @legacy_config_path + ".bak"
end

FileUtils.mkdir_p "#{ENV['HOME']}/.li"
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
# Check for local var in ~/.li/config.conf use it, else use /etc/libra/client.conf
#
def get_var(var)
    @local_config.get_value(var) ? @local_config.get_value(var) : @global_config.get_value(var)
end


require 'uri'
require 'net/https'
require 'socket'
require 'models'
require 'logger'

def http_req(url)
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host,uri.port)
  http.open_timeout = 10

  if uri.kind_of? URI::HTTPS
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

  response = nil
  begin
    response = http.get(uri.path)
  rescue Errno::ECONNREFUSED, Timeout::Error => e
    response = "Server not running"
  rescue Errno::EHOSTUNREACH
    response = "Host unreachable"
  end

  if block_given?
    yield response
  else
    return response
  end
end

def get_hostname
  http_req("http://169.254.169.254/latest/meta-data/public-hostname") do |resp|
    case resp
    when Net::HTTPSuccess
      resp.body
    else
      Socket::getaddrinfo(Socket.gethostname,nil,Socket::AF_INET).first[3]
    end
  end
end

def _log(string)
  logger = defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
  logger.debug("STATUS_APP: #{string}")
end

require 'uri'
require 'net/https'
require 'socket'
require 'models'
require 'logger'

def http_req(method,url)
  uri = URI.parse(url)
  http = Net::HTTP.new(uri.host,uri.port)
  http.open_timeout = 10

  if uri.kind_of? URI::HTTPS
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
  end

  begin
    http.start { |http| 
      http.send(method,uri.path) do |response|
        if block_given?
          yield response
        else
          return response
        end
      end
    }
  rescue Errno::ECONNREFUSED, Timeout::Error => e
    puts "\tServer not running"
  rescue Errno::EHOSTUNREACH
  end
end

def get_hostname
  http_req(:get,"http://169.254.169.254/latest/meta-data/public-hostname") || 
    Socket::getaddrinfo(Socket.gethostname,nil,Socket::AF_INET).first[3]
end

def _log(string)
  logger = defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
  logger.debug("STATUS_APP: #{string}")
end

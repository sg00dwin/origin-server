#require 'rubygems'
#require 'sinatra'
require 'webrick'
require 'webrick/https'
require 'openssl'
require 'yaml'

STATUS_APP_ROOT = File.expand_path(File.dirname(__FILE__))
$LOAD_PATH << File.join(STATUS_APP_ROOT, 'lib')

STATUS_APP_HOSTS = YAML.load(File.open(File.join(STATUS_APP_ROOT,'config','hosts.yml')))

webrick_options = {
  :Port => 443,
  :SSLEnable => true,
  :SSLVerifyClient => OpenSSL::SSL::VERIFY_NONE,
  :SSLPrivateKey => OpenSSL::PKey::RSA.new(
      File.open("/etc/pki/tls/private/localhost.key").read),
  :SSLCertificate => OpenSSL::X509::Certificate.new(
      File.open("/etc/pki/tls/certs/localhost.crt").read),
  :SSLCertName => [["CN", WEBrick::Utils::getservername]]
}

require 'status_app'
begin
  Rack::Handler::WEBrick.run StatusApp, webrick_options
rescue Errno::EADDRINUSE
  puts "Address in use, trying next one"
  webrick_options[:Port] += 1
  retry
end

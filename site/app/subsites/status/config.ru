require 'rubygems'
require 'sinatra'
require 'webrick'
require 'webrick/https'
require 'openssl'

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

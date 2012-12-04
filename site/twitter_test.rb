require 'net/http'
require 'net/https'
require 'uri'
require 'openssl'
require 'base64'

SIGNATURE_METHOD = "HMAC-SHA1"
OAUTH_VERSION = "1.0"
CONTENT_TYPE = 'application/x-www-form-urlencoded'
METHOD = 'GET'
BASE_ENDPOINT_URL = 'https://api.twitter.com/1.1'
RETWEETS_ENDPOINT_URL = BASE_ENDPOINT_URL + '/statuses/retweets_of_me.json'

def oauth_consumer_key
  ENV['TWITTER_OAUTH_CONSUMER_KEY'] || 'oZHQu1L7LI3r3pQ0QFNA'
end

def oauth_consumer_secret
  ENV['TWITTER_OAUTH_CONSUMER_SECRET'] || 'YBa7A5b101Tah08mXeqJJfS1HYh20QVzWSAO8N6IN0'
end

def oauth_token
  ENV['TWITTER_OAUTH_TOKEN'] || '17620820-tvVfJIwwg3fkvH0zhJhvQzacl28yjdnFAyOX4Pg'
end

def oauth_token_secret
  ENV['TWITTER_OAUTH_TOKEN_SECRET'] || '6qfGeqB6TsCICspBG88EnzXS5RDJazGhT8bCqyrceY'
end

def oauth_parameters
  @oauth_parameters ||= {
  	'oauth_consumer_key' => oauth_consumer_key,
  	'oauth_nonce' => oauth_nonce,
  	'oauth_signature_method' => SIGNATURE_METHOD,
  	'oauth_timestamp' => timestamp,
  	'oauth_token' => oauth_token,
  	'oauth_version' => OAUTH_VERSION
  }
end

def oauth_header
  'OAuth ' + 
  oauth_parameters.sort.map{|k,v| "#{percent_encode(k)}=\"#{percent_encode(v)}\""}.join(', ') + 
  ', ' + 
  "oauth_signature=\"#{percent_encode(oauth_signature)}\""
end

def oauth_nonce
  Array.new(5) { rand(256) }.pack('C*').unpack('H*').first
end

def oauth_signature
  signing_key = percent_encode(oauth_consumer_secret) + '&' + percent_encode(oauth_token_secret)
  signature_base_string = [
  	METHOD, 
  	percent_encode(RETWEETS_ENDPOINT_URL), 
  	percent_encode(oauth_parameters.sort.map{|k,v| "#{percent_encode(k)}=#{percent_encode(v)}"}.join('&'))
  ].join('&')
  digest = OpenSSL::Digest::Digest.new('sha1')
  hmac = OpenSSL::HMAC.digest(digest, signing_key, signature_base_string)
  Base64.encode64(hmac).chomp.gsub(/\n/, '')
end

def timestamp
  Time.now.to_i.to_s
end

def percent_encode(string)
  return URI.escape(string, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]")).gsub('*', '%2A')
end

uri = URI(RETWEETS_ENDPOINT_URL)
req = Net::HTTP::Get.new(uri.request_uri)
req['Authorization'] = oauth_header
req['Content-Type'] = CONTENT_TYPE

res = Net::HTTP.start(uri.hostname, uri.port, :use_ssl => uri.scheme == 'https') { |http|
  http.request(req)
}
puts res.body

exit 0

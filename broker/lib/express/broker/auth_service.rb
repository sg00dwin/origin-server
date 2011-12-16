require 'cgi'
require 'uri'
require 'net/http'
require 'net/https'
require 'json'
require 'singleton'
require 'cloud-sdk-common'

module Express
  module Broker
    class AuthService
      service_base_url = defined?(Rails) ? Rails.application.config.cdk[:auth_service][:host] + Rails.application.config.cdk[:auth_service][:base_url] : ""
      @@login_url = URI.parse(service_base_url + "/login.html")
      @@roles_url = URI.parse(service_base_url + "/cloudVerify.html")
      @@user_info_url = URI.parse(service_base_url + "/userInfo.html")
      
      def generate_broker_key(app)
        cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")                                                                                                                                                                 
        cipher.encrypt
        cipher.key = OpenSSL::Digest::SHA512.new(Rails.application.config.cdk[:broker_auth_secret]).digest
        cipher.iv = iv = cipher.random_iv
        token = {:app_name => app.name,
                 :rhlogin => app.user.rhlogin,
                 :creation_time => app.creation_time}
        encrypted_token = cipher.update(token.to_json)
        encrypted_token << cipher.final
      
        public_key = OpenSSL::PKey::RSA.new(File.read('/var/www/libra/broker/config/keys/public.pem'), Rails.application.config.cdk[:broker_auth_rsa_secret])
        encrypted_iv = public_key.public_encrypt(iv)
        [encrypted_iv, encrypted_token]
      end
      
      def login(request, params, cookies)
        data = JSON.parse(params['json_data'])
    
        username = nil
        if params['broker_auth_key'] && params['broker_auth_iv']
          encrypted_token = Base64::decode64(params['broker_auth_key'])
          cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
          cipher.decrypt
          cipher.key = OpenSSL::Digest::SHA512.new(Rails.application.config.cdk[:broker_auth_secret]).digest
          private_key = OpenSSL::PKey::RSA.new(File.read('config/keys/private.pem'), Rails.application.config.cdk[:broker_auth_rsa_secret])
          cipher.iv =  private_key.private_decrypt(Base64::decode64(params['broker_auth_iv']))
          json_token = cipher.update(encrypted_token)
          json_token << cipher.final
    
          token = JSON.parse(json_token)
          username = token['rhlogin']
          app_name = token['app_name']
                
          user = CloudUser.find_by_login(username)
          raise UserValidationException.new unless user
          
          app = user.applications[app_name]
          raise UserValidationException.new if !app or creation_time != app.creation_time
          return username
        else
          return data['rhlogin']
          ticket = cookies[:rh_sso]
          rhlogin = nil
          roles = []
          begin
            http_post(@@roles_url,{},ticket) do |json|
              rhlogin = json['username'] || json['login']
              roles = json['roles']      
            end
            check_access(roles)
            return rhlogin
          rescue Cloud::Sdk::UserValidationException
            Rails.logger.debug("Attempted to use previous ticket '#{@ticket}' to establish but failed with AccessDenied.  Continuing with normal login...")
          end
    
          login_args = {'login' => data['rhlogin'], 'password' => params['password']}
          # Establish the authentication ticket
          http_post(@@login_url, login_args) do |json|
            Rails.logger.debug("Current login = #{data['rhlogin']} / authenticated for #{json['username'] || json['login']}")
            rhlogin = json['username'] || json['login']
            roles = json['roles']
          end
          check_access(roles)
          return rhlogin
        end
      end
      
      private
      
      def check_access(roles)
        roles = [] unless roles
        unless roles.index('cloud_access_1')
          if roles.index('cloud_access_request_1')
            raise UserValidationException.new("Found valid credentials but you haven't been granted access to Express yet", 146), caller[0..5]
          else
            raise UserValidationException.new("Found valid credentials but you haven't requested access to Express yet", 147), caller[0..5]
          end
        end
      end
      
      def http_post(url, args={}, ticket=nil)
        begin
          req = Net::HTTP::Post.new(url.path + (url.query ? ('?' + url.query) : ''))
          req.set_form_data(args)
    
          # Include the ticket as a cookie if present
          req.add_field('Cookie', "rh_sso=#{ticket}") if ticket
    
          http = Net::HTTP.new(url.host, url.port)
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    
          # Add timing code
          start_time = Time.now
          res = http.start {|http| http.request(req)}
          end_time = Time.now
          Rails.logger.debug "Response from Streamline took (#{url.path}): #{(end_time - start_time)*1000} ms"
    
          case res
          when Net::HTTPSuccess, Net::HTTPRedirection
            Rails.logger.debug("POST Response code = #{res.code}")
    
            # Set the rh_sso cookie as the ticket
            parse_ticket(res.get_fields('Set-Cookie'))
    
            # Parse and yield the body if a block is supplied
            if res.body and !res.body.empty?
              json = JSON.parse(res.body)
              yield json if block_given?
            else
              Rails.logger.error "Empty response from streamline - #{res.code}"
              raise AuthServiceException
            end
          when Net::HTTPForbidden, Net::HTTPUnauthorized
            raise AccessDeniedException
          else
            Rails.logger.error "Invalid HTTP response from streamline - #{res.code}"
            Rails.logger.error "Response body:\n#{res.body}"
            raise AuthServiceException
          end
        rescue Cloud::Sdk::AccessDeniedException, Cloud::Sdk::UserValidationException, Cloud::Sdk::AuthServiceException
          raise
        rescue Exception => e
          Rails.logger.error "Exception occurred while calling streamline - #{e.message}"
          Rails.logger.error e, e.backtrace
          raise AuthServiceException
        end
      end
      
      #
      # Parse the rh_sso cookie out of the headers
      # and set it as the ticket
      #
      def parse_ticket(cookies)
        if cookies
          cookies.each do |cookie|
            if cookie.index("rh_sso")
              @ticket = cookie.split('; ')[0].split("=")[1]
              break
            end
          end
        end
      end
    end
  end
end
require 'cgi'
require 'uri'
require 'net/http'
require 'net/https'
require 'json'
require 'singleton'
require 'stickshift-common'

module Swingshift
    class StreamlineAuthService < StickShift::AuthService
      service_base_url = defined?(Rails) ? Rails.configuration.auth[:auth_service][:host] + Rails.configuration.auth[:auth_service][:base_url] : ""
      @@login_url = URI.parse(service_base_url + "/login.html")
      @@roles_url = URI.parse(service_base_url + "/cloudVerify.html")
      @@user_info_url = URI.parse(service_base_url + "/userInfo.html")
      
      def generate_broker_key(app)
        cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")                                                                                                                                                                 
        cipher.encrypt
        cipher.key = OpenSSL::Digest::SHA512.new(Rails.configuration.auth[:broker_auth_secret]).digest
        cipher.iv = iv = cipher.random_iv
        token = {:app_name => app.name,
                 :rhlogin => app.user.login,
                 :creation_time => app.creation_time}
        encrypted_token = cipher.update(token.to_json)
        encrypted_token << cipher.final
      
        public_key = OpenSSL::PKey::RSA.new(File.read('/var/www/stickshift/broker/config/keys/public.pem'), Rails.configuration.auth[:broker_auth_rsa_secret])
        encrypted_iv = public_key.public_encrypt(iv)
        [encrypted_iv, encrypted_token]
      end
      
      def authenticate(request, login, password)
        if request.headers['User-Agent'] == "StickShift"
          return check_broker_key(login, password)
        else
          unless Rails.configuration.auth[:integrated]
            token = {:username => login, :auth_method => :login}
          else
            token = check_login(request, login, password)
          end
        end
        Rails.logger.debug "Adding user #{login}...inside authenticate"
        cloud_user = CloudUser.find login
        if cloud_user.nil?
           cloud_user = CloudUser.new(login)
           cloud_user.save
        end
        return token
      end
      
      def login(request, params, cookies)
        data = JSON.parse(params['json_data'])
        token = nil
        username = nil
        if params['broker_auth_key'] && params['broker_auth_iv']
          token = check_broker_key(params['broker_auth_key'],params['broker_auth_iv'])
        else
          login = data['rhlogin']
          unless Rails.configuration.auth[:integrated]
            token = {:username => data['rhlogin'], :auth_method => :login}
          else
            password = params['password']
            token =  check_login(request, login, password)
          end
        end
        if token
          username = token[:username]
          Rails.logger.debug "Adding user #{username}...inside login"
          cloud_user = CloudUser.find username
          if cloud_user.nil?
            cloud_user = CloudUser.new(username)
            cloud_user.save
          end
        end
        return token
      end
      
      private
      
      def check_login(request, user, password)
        ticket = request.cookies['rh_sso']
        rhlogin = nil
        if ticket
          begin
            login = nil
            roles = []
            http_post(@@roles_url,{},ticket) do |json|
              login = json['username'] || json['login']
              roles = json['roles']      
            end
            check_access(roles)
            rhlogin = login
          rescue
            Rails.logger.debug("Attempted to use previous ticket '#{ticket}' to establish but failed. Continuing with normal login...")
          end
        end

        unless rhlogin
          begin
            return rhlogin if not user or not password
            login_args = {'login' => user, 'password' => password}
            # Establish the authentication ticket
            login = nil
            roles = []
            http_post(@@login_url, login_args) do |json|
              Rails.logger.debug("Current login = #{user} / authenticated for #{json['username'] || json['login']}")
              login = json['username'] || json['login']
              roles = json['roles']
            end
            check_access(roles)
            rhlogin = login
          #rescue StickShift::AccessDeniedException
          end
        end
        
        {:username => rhlogin, :auth_method => :login}
      end
      
      def check_broker_key(key, iv)
        key = key.gsub(" ", "+")
        iv = iv.gsub(" ", "+")
        encrypted_token = Base64::decode64(key)
        cipher = OpenSSL::Cipher::Cipher.new("aes-256-cbc")
        cipher.decrypt
        cipher.key = OpenSSL::Digest::SHA512.new(Rails.configuration.auth[:broker_auth_secret]).digest
        private_key = OpenSSL::PKey::RSA.new(File.read('config/keys/private.pem'), Rails.configuration.auth[:broker_auth_rsa_secret])
        cipher.iv =  private_key.private_decrypt(Base64::decode64(iv))
        json_token = cipher.update(encrypted_token)
        json_token << cipher.final
  
        token = JSON.parse(json_token)
        username = token['rhlogin']
        app_name = token['app_name']
        creation_time = token['creation_time']
              
        user = CloudUser.find(username)
        raise StickShift::UserValidationException.new unless user
        
        app = Application.find(user, app_name)
        
        raise StickShift::UserValidationException.new if !app or creation_time != app.creation_time
        return {:username => username, :auth_method => :broker_auth}
      end
      
      def check_access(roles)
        roles = [] unless roles
        unless roles.index('cloud_access_1')
          if roles.index('cloud_access_request_1')
            raise StickShift::UserValidationException.new("Found valid credentials but you haven't been granted access yet", 146)
          else
            raise StickShift::UserValidationException.new("Found valid credentials but you haven't requested access yet", 147)
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
    
            # Parse and yield the body if a block is supplied
            if res.body and !res.body.empty?
              json = JSON.parse(res.body)
              yield json if block_given?
            else
              Rails.logger.error "Empty response from streamline - #{res.code}"
              raise StickShift::AuthServiceException
            end
          when Net::HTTPForbidden, Net::HTTPUnauthorized
            raise StickShift::AccessDeniedException
          else
            Rails.logger.error "Invalid HTTP response from streamline - #{res.code}"
            Rails.logger.error "Response body:\n#{res.body}"
            raise StickShift::AuthServiceException
          end
        rescue StickShift::AccessDeniedException, StickShift::UserValidationException, StickShift::AuthServiceException
          raise
        rescue Exception => e
          Rails.logger.error "Exception occurred while calling streamline - #{e.message}"
          Rails.logger.error e, e.backtrace
          raise StickShift::AuthServiceException
        end
      end
    end
end

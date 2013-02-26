require 'uri'
require 'net/http'
require 'net/https'
require 'json'

module OpenShift
  class StreamlineAuthService

    def initialize
      service_base_url = Rails.configuration.auth[:auth_service][:host] + Rails.configuration.auth[:auth_service][:base_url]
      @login_url = URI.parse(service_base_url + "/login.html")
      @roles_url = URI.parse(service_base_url + "/cloudVerify.html")
      @user_info_url = URI.parse(service_base_url + "/userInfo.html")
    end

    def authenticate_request(controller)
      controller.authenticate_with_http_basic do |u, p|
        if Rails.configuration.auth[:integrated]
          check_login(controller.request.cookies['rh_sso'], u, p)
        else
          u.present? ? {username: u} : nil
        end
      end
    end

    def authenticate(login, password)
      if Rails.configuration.auth[:integrated]
        check_login(nil, login, password)
      else
        {:username => login}
      end
    end

    private

    def check_login(ticket, user, password)
      rhlogin = nil
      is_cached = false

      if ticket
        # check for presence of rh_sso cookie in the auth cache
        begin
          json = get_cache(ticket)
          if json
            is_cached = true
          else
            Rails.logger.debug("Login information for ticket '#{ticket}' not available in cache. Continuing with streamline authentication for the ticket...")
            json, ticket = http_post(@roles_url, {}, ticket)
          end

          login = json['username'] || json['login']
          roles = json['roles']

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
          json, ticket = http_post(@login_url, login_args)
          Rails.logger.debug("Current login = #{user} / authenticated for #{json['username'] || json['login']}")
          login = json['username'] || json['login']
          roles = json['roles']

          check_access(roles)
          rhlogin = login
        end
      end

      # store the validated ticket and login info in the cache for 5 minutes
      # Write to cache only if the ticket is not already present in the cache
      write_cache(ticket, json, :expires_in => 300.seconds) unless is_cached

      {:username => rhlogin}
    end

    def check_access(roles)
      roles = [] unless roles
      unless roles.index('cloud_access_1')
        if roles.index('cloud_access_request_1')
          raise OpenShift::UserValidationException.new("Found valid credentials but you haven't been granted access yet", 146)
        else
          raise OpenShift::UserValidationException.new("Found valid credentials but you haven't requested access yet", 147)
        end
      end
    end

    def get_cache(key)
      if Rails.configuration.action_controller.perform_caching
        Rails.cache.read(key)
      else
        nil
      end
    rescue
      Rails.logger.error("Failed to read auth cookie from cache")
      nil
    end

    def write_cache(key, val, opts={})
      if Rails.configuration.action_controller.perform_caching
        begin
          Rails.cache.write(key, val, opts)
        rescue
          Rails.logger.error("Failed to write auth cookie to cache")
        end
      end
    end

    def http_post(url, args={}, ticket=nil)
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

        cookies = res.get_fields('Set-Cookie')
        if cookies
          cookies.each do |cookie|
            if cookie.index("rh_sso")
              ticket = cookie.split('; ')[0].split("=")[1]
              break
            end
          end
        end

        # Parse and yield the body if a block is supplied
        if res.body and !res.body.empty?
          json = JSON.parse(res.body)
          return json, ticket
        else
          Rails.logger.error "Empty response from streamline - #{res.code}"
          raise OpenShift::AuthServiceException
        end
      when Net::HTTPForbidden, Net::HTTPUnauthorized
        raise OpenShift::AccessDeniedException
      else
        Rails.logger.error "Invalid HTTP response from streamline - #{res.code}"
        Rails.logger.error "Response body:\n#{res.body}"
        raise OpenShift::AuthServiceException
      end
    rescue OpenShift::AccessDeniedException, OpenShift::UserValidationException, OpenShift::AuthServiceException
      raise
    rescue Exception => e
      Rails.logger.error "Exception occurred while calling streamline - #{e.message}"
      Rails.logger.error e, e.backtrace
      raise OpenShift::AuthServiceException
    end
  end
end

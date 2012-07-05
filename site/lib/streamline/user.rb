module Streamline
  module User
    require_dependency "streamline"

    #
    # Establish the user state based on the current ticket
    #
    # Returns the login
    #
    # <b>DEPRECATED:</b> Use establish_roles
    def establish
      roles
      self
    end

    def establish_terms
      terms
    end

    def terms
      @terms ||= http_post(unacknowledged_terms_url) do |json|
        json['unacknowledgedTerms'] || []
      end
    end

    def roles
      super or roles!
    end
    def roles!
      self.roles = http_post(roles_url) do |json|
        @rhlogin ||= json['username']
        Rails.logger.warn "Roles user #{json['username']} different than active #{rhlogin}" if rhlogin != json['username']
        json['roles'] || []
      end
    end
    def streamline_type!
      roles!
      streamline_type
    end

    def refresh_roles(force=false)
      has_requested = force
      CloudAccess::IDS.each do |id|
        if has_requested?(id)
          has_requested = true
          break
        end
      end unless has_requested
      if has_requested
        roles
      end
    end

    def authenticate!(login, password)
      authenticate(login, password) or raise Streamline::AuthenticationDenied
      self
    end

    # Clears the current ticket and authenticates with streamline
    def authenticate(login, password)
      self.ticket = nil
      Rails.logger.debug "  Authenticating user #{login}"
      errors.clear

      http_post(login_url, {:login => login, :password => password}) do |json|
        self.roles = json['roles']
        self.rhlogin = json['login']
      end
      true
    rescue AccessDeniedException
      errors.add(:base, I18n.t(:login_error, :scope => :streamline))
      false
    rescue Streamline::StreamlineException
      errors.add(:base, I18n.t(:service_error, :scope => :streamline))
      false
    end

    def logout
      return unless @ticket

      # Make the request
      req = Net::HTTP::Get.new( logout_url.request_uri )
      req['Cookie'] = "rh_sso=#{@ticket}"

      # Create the request
      # Add timing code
      ActiveSupport::Notifications.instrument("request.streamline", {
        :uri => logout_url.request_uri,
        :method => 'logout'
      }) do |payload|

        res = new_http.start{ |http| http.request(req) }
        payload[:code] = res.code

        unless 302 == res.code.to_i
          Rails.logger.error "Streamline returned an unexpected response to logout"
          Rails.logger.error res.to_yaml
        end
      end
    end

    def accepted_terms?
      terms && terms.empty?
    end

    def accept_terms
      Rails.logger.debug("Calling streamline to accept terms")
      errors.clear
      unless terms.empty?
        http_post(build_terms_url(terms), {}, false) do |json|
          # Log error on unknown result
          Rails.logger.error("Streamline accept terms failed") unless json['term']
    
          # Unless everything was accepted, put an error on the user object
          json['term'] ||= []

          # Convert the accepted ids to strings to comparison
          # normally they are integers
          terms_ids = @terms.map{|hash| hash['termId'].to_s}
          if (terms_ids - json['term']).empty?
            @terms.clear
          else
            Rails.logger.error("Streamline partial terms acceptance. Expected #{terms_ids} got #{json['term']}")
            errors.add(:base, I18n.t(:terms_error, :scope => :streamline))
          end
        end
      end
      errors.empty?
    end

    #
    # When invoked with no arguments behaves like an ActiveModel call to save the resource with
    # an updated password, assuming  @old_password, @password, and @password_confirmation are 
    # all set. Will invoke 'valid? :change_password' on the resource to ensure that validations
    # are called.  The return value is true if successful and errors are set.
    #
    def change_password(args=nil)
      if args.nil?
        if valid? :change_password
          args = {
            'oldPassword' => old_password,
            'newPassword' => password,
            'newPasswordConfirmation' => password
          }
          http_post(change_password_url, args) do |json|
            if json['errors']
              field = :password
              if json['errors'].include? 'password_incorrect'
                msg = 'Your old password was incorrect'
                field = :old_password
              elsif json['errors'].include? 'password_invalid'
                msg = 'Please choose a valid new password'
              else
                msg = 'Your password could not be changed'
              end
              errors.add(field, msg)
            end
            errors.empty?
          end
        end
      else
        # <b>DEPRECATED</b> Will be removed
        http_post(change_password_url, args) do |json|
          return json
        end
      end
    end

    #
    # When invoked with no arguments behaves like an ActiveModel call to save the resource with
    # an updated password, assuming  @old_password, @password, and @password_confirmation are 
    # all set. Will invoke 'valid? :change_password' on the resource to ensure that validations
    # are called.  The return value is true if successful and errors are set.
    #
    def change_password_with_token
      if valid? :change_password
        args = {
          :login => login,
          :token => token,
          :newPassword => password,
          :newPasswordConfirmation => password_confirmation
        }
        http_post(change_password_url, args) do |json|
          if json['errors']
            field = :password
            if json['errors'].include? 'password_incorrect'
              msg = 'Your old password was incorrect'
              field = :old_password
            elsif json['errors'].include? 'password_invalid'
              msg = 'Please choose a valid new password'
            else
              msg = 'Your password could not be changed'
            end
            errors.add(field, msg)
          else
            self.token = nil # token is consumed by change
          end
          errors.empty?
        end
      end
    end

    #
    # When called with a single string argument behaves like an ActiveModel call to 
    # save the resource.  It will use the @email_address instance variable and invoke
    # 'valid? :reset_password' to ensure validations are called.  The return value is
    # true if successful and errors are set.
    def request_password_reset(args)
      if args.is_a? String
        if valid? :reset_password
          args = {
            :login => login,
            :url => args
          }
          http_post(request_password_reset_url, args, false) do |json|
            Rails.logger.debug "Password reset request #{json.inspect}"
            self.token = json['token'] if json['token']
          end
          errors.empty?
        end
      else
        http_post(request_password_reset_url, args, false) do |json|
          return json
        end
      end
    end

    def reset_password(args)
      http_post(reset_password_url, args) do |json|
        return json
      end
    end

    def complete_reset_password(token)
      args = {
        :login => @rhlogin,
        :token => token
      }
      http_post(reset_password_url, args, false) do |json|
        Rails.logger.debug "Password reset completion #{json.inspect}"
        if json['errors']
          raise TokenExpired if 'token_is_invalid' == json['errors'].first
          errors.add(:base, I18n.t(:unknown)) if errors.empty?
        end
      end
      errors.empty?
    end

    def check_access
      unless roles.index('cloud_access_1')
        if roles.index('cloud_access_request_1')
          raise Streamline::UserValidationException.new(146), "Found valid credentials but you haven't been granted access yet", caller[0..5]
        else
          raise Streamline::UserValidationException.new(147), "Found valid credentials but you haven't requested access yet", caller[0..5]
        end
      end
    end

    #
    # Register a new streamline user
    #
    def register(confirm_url, promo_code=nil)
      register_args = {'emailAddress' => email_address,
                       'password' => password,
                       'passwordConfirmation' => password,
                       'secretKey' => Rails.configuration.streamline[:register_secret],
                       'termsAccepted' => 'true',
                       'confirmationUrl' => confirm_url}
      register_args['promoCode'] = promo_code if promo_code

      http_post(register_url, register_args, false) do |json|
        Rails.logger.debug "Registration response #{json.inspect}"
        if json['emailAddress']
          self.email_address = json['emailAddress']
          self.token = json['email_verification_token']
        else
          if errors.length == 0
            errors.add(:base, I18n.t(:unknown))
          end
        end
      end
      errors.empty?
    end

    def confirm_email(token=self.token,email=self.email_address)
      raise "No email address provided" unless email
      raise "No verification key provided" unless token
      confirm_args = {
        :emailAddress => email,
        :key => token
      }
      errors.clear
      http_post(email_confirm_url, confirm_args, false) do |json|
        Rails.logger.debug "Confirmation response #{json.inspect}"
        Rails.logger.debug "  Ticket #{@ticket}"
        if json['emailAddress'] or json['login']
          self.roles = json['roles']
          self.rhlogin = json['login']
          self.token = nil # token is consumed by confirmation
          # success
        elsif json['errors'] and json['errors'][0] == 'user_already_registered'
          # success
          errors.clear
        else
          if errors.length == 0
            errors.add(:base, I18n.t(:unknown))
          end
        end
      end
      errors.empty?
    end

    #
    # Request access to a cloud solution
    #<b>DEPRECATED</b>: Use entitled?
    def request_access(solution)
      if has_requested?(solution)
        Rails.logger.warn("User already requested access")
        errors.add(:base, I18n.t(:already_requested_access, :scope => :streamline))
      elsif has_access?(solution)
        Rails.logger.warn("User already granted access")
        errors.add(:base, I18n.t(:already_granted_access, :scope => :streamline))
      else
        access_args = {'solution' => solution}
        # Make the request for access
        http_post(request_access_url, access_args, false) do |json|
          if json['solution']
            # success
          else
            if errors.length == 0
              errors.add(:base, I18n.t(:unknown))
            end
          end
        end
      end
    end

    #
    # Get the user's email address.  Will raise on error
    #
    def load_email_address
      @email_address = Rails.cache.fetch([Streamline::User.name, :email_by_login, @rhlogin], :expires_in => 5.minutes) do
        user_info_args = {
          'login' => @rhlogin,
          'secretKey' => Rails.configuration.streamline[:user_info_secret]
        }
        http_post(user_info_url, user_info_args) do |json|
          json['emailAddress']
        end
      end
    end

    #
    # Whether the user is authorized for a given cloud solution
    #<b>DEPRECATED</b>: Use entitled?
    def has_access?(solution)
      @roles.nil? ? false : @roles.index(CloudAccess.auth_role(solution)) != nil
    end

    #
    # Whether the user has already requested access for a given cloud solution
    #
    #<b>DEPRECATED</b>: Use waiting_for_entitle?
    def has_requested?(solution)
      @roles.nil? ? false : @roles.index(CloudAccess.req_role(solution)) != nil
    end

    # Return true if the user has access to OpenShift, and false if they are not yet
    # granted.  If false is returned call waiting_for_entitlement?  Will attempt to
    # request access if the user has never requested it.
    def entitled?
      return true if roles.include?('cloud_access_1')

      if roles.include?('cloud_access_request_1')
        false
      else
        http_post(request_access_url, {'solution' => CloudAccess::EXPRESS}, false) do |json|
          if json['solution']
            refresh_roles(true)
            true
          else
            false
          end
        end
      end
    end

    # Return true if the user is currently waiting to be entitled.  No side effects
    def waiting_for_entitle?
      not roles.include?('cloud_access_1') and roles.include?('cloud_access_request_1')
    end

    protected
      def new_http
        Net::HTTP.new(service_base_url.host, service_base_url.port).tap do |http|
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          http.read_timeout = Rails.application.config.streamline[:timeout] || 5
          http.set_debug_output($stdout) if ENV['STREAMLINE_DEBUG']
        end
      end

      def http_post(url, args={}, raise_exception_on_error=true)
        begin
          req = Net::HTTP::Post.new(url.request_uri)
          req.set_form_data(args)

          # Include the ticket as a cookie if present
          req.add_field('Cookie', "rh_sso=#{@ticket}") if @ticket

          ActiveSupport::Notifications.instrument("request.streamline",
            :uri => url.request_uri,
            :method => caller[0][/`.*'/][1..-2],
            :args => FilterHash.safe_values(args).inspect
          ) do |payload|

            res = new_http.start {|http| http.request(req)}

            payload[:code] = res.code
            json = parse_body(res.body) if res.body && !res.body.empty?
            payload[:response] = json.inspect
            parse_ticket(res.get_fields('Set-Cookie'))

            case res
            when Net::HTTPSuccess, Net::HTTPRedirection
              unless json
                if raise_exception_on_error
                  raise Streamline::StreamlineException, "No JSON in response"
                else
                  errors.add(:base, I18n.t(:unknown))
                end
              end
              yield json if block_given?
            when Net::HTTPForbidden, Net::HTTPUnauthorized
              raise Streamline::StreamlineException, "Server error" if json && json['errors'] && json['errors'].include?('service_error')
              raise AccessDeniedException, "Streamline rejected the request (#{res.code})\n#{res.body}"
            else
              Rails.logger.error "Streamline returned an unexpected response"
              Rails.logger.error res.to_yaml
              if raise_exception_on_error
                raise Streamline::StreamlineException, "Invalid HTTP response from streamline (#{res.code})\n#{res.body}"
              else
                errors.add(:base, I18n.t(:unknown))
              end
            end
          end

        rescue AccessDeniedException, Streamline::UserValidationException, Streamline::StreamlineException
          raise
        rescue Exception => e
          Rails.logger.error "Exception occurred while calling streamline - #{e}\n  #{e.backtrace.join("\n  ")}"
          if raise_exception_on_error
            raise Streamline::StreamlineException#, "Unable to communicate with streamline: #{$!}", $!.backtrace
          else
            errors.add(:base, I18n.t(:unknown))
          end
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
              self.ticket = cookie.split('; ')[0].split("=")[1]
              break
            end
          end
        end
      end

      #
      # Parse the response body, setting errors on the
      # user object as necessary.  Returns json structure
      #
      def parse_body(body)
        if body
          json = ActiveSupport::JSON::decode(body)
          parse_json_errors(json)
          return json
        end
      end

      def parse_json_errors(json)
        if json and json['errors']
          json['errors'].each do |error|
            msg = I18n.t error, :scope => :streamline, :default => I18n.t(:unknown)
            # Adding to :base is important for errors.full_messages to generate
            # appropriate error messages
            errors.add(:base, msg)
          end
        end
      end

      def build_terms_query(terms)
        terms.collect {|hash| "termIds=#{hash['termId']}"}.join('&') if terms
      end

      def build_terms_url(terms)
        url = acknowledge_terms_url.clone
        url.query = build_terms_query(terms)
        url
      end

    private
      def service_base_url
        @service_base_url ||= if defined?(Rails)
          uri = URI.parse(Rails.configuration.streamline[:host] + Rails.configuration.streamline[:base_url])
          uri.path = uri.path + '/' if uri.path && uri.path[-1,1] != '/'
          uri
        end
      end

      def login_url; service_base_url.merge("login.html"); end
      def logout_url; service_base_url.merge("../sso/logout.html"); end
      def register_url; service_base_url.merge("registration.html"); end

      def request_access_url; service_base_url.merge("requestAccess.html"); end
      def roles_url; service_base_url.merge("cloudVerify.html"); end
      def email_confirm_url; service_base_url.merge("confirm.html"); end
      #def email_confirm_url(key, login)
      #  query = "key=#{key}&emailAddress=#{CGI::escape(login)}"
      #  URI.parse("#{email_confirm_url}?#{query}")
      #end

      def user_info_url; service_base_url.merge("userInfo.html"); end

      def acknowledge_terms_url; service_base_url.merge("protected/acknowledgeTerms.html"); end
      def unacknowledged_terms_url; service_base_url.merge("protected/findUnacknowledgedTerms.html?hostname=openshift.redhat.com&context=OPENSHIFT&locale=en"); end

      def change_password_url; service_base_url.merge('protected/changePassword.html'); end
      def request_password_reset_url; service_base_url.merge('resetPassword.html'); end
      def reset_password_url; service_base_url.merge('resetPasswordConfirmed.html'); end
  end
end

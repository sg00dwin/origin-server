module Aria
  class Client
    require_dependency 'aria/errors'
    include HTTParty

    config = Rails.configuration

    debug_output if ENV['ARIA_DEBUG']
    parser Aria::WDDX
    base_uri config.aria_uri
    default_params :client_no => config.aria_client_no
    default_params :auth_key => config.aria_auth_key
    headers 'User-Agent' => config.user_agent

    def respond_to?(meth)
      super
    end

    def method_missing(meth, *args, &block)
      return super if Object.method_defined? meth

      options = args.extract_options!
      meth = meth.to_s
      raw = true if meth.sub!(/_raw$/, '')

      raise ArgumentError, "Aria::Client#<method> requires no arguments, or a hash of options. Remove #{args.inspect}" unless args.empty?

      ActiveSupport::Notifications.instrument("request.aria",
        :uri => self.class.base_uri,
        :method => meth
      ) do |payload|

        resp = self.class.post('', :query => { :rest_call => meth }, :body => options)

        raise Aria::InvalidMethod, meth if resp.code == 404 && resp.data && resp.data[:error_code] == -1
        payload[:code] = resp.code
        raise Aria::NotAvailable.new(resp) unless resp.code == 200
        payload[:error_code] = error_code = resp.data.error_code
        raise Aria::Errors[error_code].new(resp) if Aria::Errors[error_code]
        raise Aria::Error.new(resp) unless error_code == 0

        (yield(resp.data, resp) if block_given?) or raw ? resp : resp.data
      end
    end

    include Aria::Methods
  end
end

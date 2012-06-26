
module Aria
  class Client
    require_dependency 'aria/errors'

    include HTTParty

    config = Rails.application.config

    debug_output if ENV['ARIA_DEBUG']
    parser Aria::WDDX
    base_uri config.aria_uri
    default_params :client_no => config.aria_client_no
    default_params :auth_key => config.aria_auth_key

    def respond_to?(meth)
      true
    end

    def method_missing(meth, *args, &block)
      options = args.extract_options!
      meth = meth.to_s
      raw = true if meth.sub!(/_raw$/, '')

      resp = self.class.post('', :query => options.merge(:rest_call => meth))

      raise Aria::InvalidMethod, meth if resp.code == 404 && resp.data && resp.data[:error_code] == -1
      raise Aria::NotAvailable.new(resp) unless resp.code == 200
      error_code = resp.data.error_code
      raise Aria::Errors[error_code].new(resp) if Aria::Errors[error_code]
      raise Aria::Error.new(resp) unless error_code == 0

      (yield(resp.data, resp) if block_given?) or raw ? resp : resp.data
    end

    include Aria::Methods
  end
end

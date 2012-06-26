module Aria
  # An error reported by the Aria service
  class Error < StandardError
    attr_reader :data
    def initialize(*args)
      if args[0].respond_to? :data
        @data = args[0].data
        code = @data['error_code'].to_i
        message = @data['error_msg']
        super message ? "#{message} (#{code})" : code
      else
        super args[0]
      end
    end
    def code
      data['error_code']
    end
  end
  Errors = {
    # The server rejected the connection request, usually disallowed
    # through IP but also auth_key or client_no could be wrong.
    1004 => (AuthenticationError = Class.new(Error)),
    1009 => (AccountDoesNotExist = Class.new(Error)),
    1010 => (MissingRequiredParameter = Class.new(Error)),
  }

  # The Aria account has no RHLogin, which means it was not properly created
  UserNoRHLogin = Class.new(Aria::Error)
  # MD5(user_id) collision between two users, play the lottery
  UserIdCollision = Class.new(Aria::Error)

  # The Aria method you have requested does not exist
  InvalidMethod = Class.new(StandardError)
  # The Aria service is not responding
  class NotAvailable < StandardError
    attr_reader :response
    def initialize(response)
      @response = response
      super "Aria is not responding (#{response.code})"
    end
  end
end

#
# This mixin encapsulates calls made back to the IT systems via
# the streamline REST service.
#
module Streamline
  class Error < StandardError
    attr :exit_code
    def initialize(exit_code=nil)
      @exit_code = exit_code
    end
  end
  class UserException < Error; end
  class UserValidationException < Error; end
  class StreamlineException < Error
    def initialize(message=nil)
      super(message)
      @exit_code = 144
    end
  end
  # Raised when the reset token has already been used
  class TokenExpired < StreamlineException; end
  # The user name or password is invalid
  class AuthenticationDenied < StreamlineException; end

end

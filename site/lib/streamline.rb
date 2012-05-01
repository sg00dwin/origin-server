#
# This mixin encapsulates calls made back to the IT systems via
# the streamline REST service.
#
module Streamline
  include ErrorCodes

  class Cookie
    def initialize(*arguments)
      @name, @value, @options = arguments
    end
    def to_s
      "#{@name}=#{@value}"
    end
  end

  class OpenShiftException < StandardError
    attr :exit_code
    def initialize(exit_code)
      @exit_code = exit_code
    end
  end
  class UserException < OpenShiftException; end
  class UserValidationException < OpenShiftException; end
  class StreamlineException < OpenShiftException
    def initialize
      @exit_code = 144
    end
  end
  # Raised when the reset token has already been used
  class TokenExpired < Streamline::StreamlineException
  end

end

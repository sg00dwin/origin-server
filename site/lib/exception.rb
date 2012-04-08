module Streamline
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
end

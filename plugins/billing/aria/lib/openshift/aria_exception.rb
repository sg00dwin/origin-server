module OpenShift
  class AriaException < StandardError;end
  class AriaErrorCodeException < OpenShift::AriaException
    attr_accessor :error_code
    def initialize(msg, error_code)
      super(msg)
      @error_code = error_code
    end
  end
end

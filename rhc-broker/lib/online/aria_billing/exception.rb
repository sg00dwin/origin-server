module Online
  module AriaBilling
    class Exception < StandardError;end
    class ErrorCodeException < Online::AriaBilling::Exception
      attr_accessor :error_code
      def initialize(msg, error_code)
        super(msg)
        @error_code = error_code
      end
    end
  end
end

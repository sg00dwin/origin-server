module Cloud
  module Sdk
    class CdkException < StandardError
      attr_accessor :code, :resultIO
      
      def initialize(msg=nil,code=nil,resultIO=nil)
        super(msg)
        @code = code
        @resultIO = resultIO
      end
    end
    
    class NodeException < Cloud::Sdk::CdkException; end
    class UserException < Cloud::Sdk::CdkException; end
    class AuthServiceException < Cloud::Sdk::CdkException; end
    class UserValidationException < Cloud::Sdk::CdkException; end
    class AccessDeniedException < UserValidationException; end
    class DNSException < Cloud::Sdk::CdkException; end
    class DNSNotFoundException < DNSException; end
  end
end
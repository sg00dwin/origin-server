module Cloud
  module Sdk
    class CdkException < StandardError
      attr_accessor :code
      
      def initialize(msg=nil,code=nil)
        super(msg)
        @code = code
      end
    end
    
    class NodeException < CdkException; end
  end
end
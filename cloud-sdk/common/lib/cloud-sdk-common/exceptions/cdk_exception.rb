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
    
    class NodeException < CdkException; end
    class WorkflowException < Cloud::Sdk::CdkException; end
  end
end
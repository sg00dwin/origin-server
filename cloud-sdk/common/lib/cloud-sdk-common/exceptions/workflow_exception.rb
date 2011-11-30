module Cloud
  module Sdk
    class WorkflowException < Cloud::Sdk::CdkException
      def initialize(msg=nil,code=nil)
        super(msg,code)
      end
    end
  end
end
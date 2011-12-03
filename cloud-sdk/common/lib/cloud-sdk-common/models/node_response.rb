module Cloud
  module Sdk
    class NodeResponse < Model
      def initialize
        @debugIO = StringIO.new
        @resultIO = StringIO.new
        @messageIO = StringIO.new
        @errorIO = StringIO.new
        @appInfoIO = StringIO.new
      end
    end
  end
end
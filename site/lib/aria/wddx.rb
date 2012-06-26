class WDDX::Deserializer::Deserializer
  protected
    attr_writer :wddx_packet
end
class WDDX::Deserializer::Listener
  protected
    attr_reader :stack
end
class WDDX::Deserializer::Node
  attr_reader :type
end

module Aria
  class WDDX < HTTParty::Parser
    class CustomDeserializer < ::WDDX::Deserializer::Deserializer
      def initialize(xml_string)
        listener = CustomListener.new
        parser = REXML::Parsers::StreamParser.new(xml_string, listener)
        parser.parse
        self.wddx_packet = listener.wddx_packet
      end
    end
    class CustomListener < ::WDDX::Deserializer::Listener
      def tag_start(name, attributes)
        node = CustomNode.new(name, attributes)
        parent = stack.last
        parent.children << node
        stack << node
      end
    end
    class CustomNode < ::WDDX::Deserializer::Node
      def to_ruby
        case type.downcase
        when 'struct'
          Struct.new(children.inject({}) {|mem, c| var = c.to_ruby; mem[var.key] = var.value; mem})
        else
          super
        end
      end
    end
    class Struct
      def initialize(attributes={})
        @attributes = attributes
      end
      def [](attr)
        @attributes[attr.to_s]
      end
      def []=(attr, value)
        attr = attr.to_s
        if @attributes.has_key? attr
          @attributes[attr] = value
        else
          nil
        end
      end
      def method_missing(meth, *args, &block)
        meth = meth.to_s

        # setter
        if meth[-1,1] == '='
          key = meth[0..-2]
          raise ArgumentError if args.length != 1
          raise NoMethodError, meth unless @attributes.has_key? key
          @attributes[key] = args[0]

        # getter
        elsif @attributes.has_key? meth
          raise ArgumentError if args.length > 0
          @attributes[meth]

        else
          raise NoMethodError, meth
        end
      end
      def respond_to?(meth)
        meth = meth.to_s
        meth = meth[0..-2] if meth[-1,1] == '='
        @attributes.has_key?(meth) or super
      end
    end

    def parse
      CustomDeserializer.new(body).wddx_packet
    end
  end
end

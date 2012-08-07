module Aria
  class Base
    include ActiveModel::Serialization
    include ActiveModel::Validations
    include ActiveModel::AttributeMethods
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    attribute_method_suffix '='
    attribute_method_suffix ''

    attr_reader :attributes

    def initialize(opts=nil, persisted=false)
      @attributes = {}
      opts.each_pair do |k,v|
        send("#{k}=", v) if respond_to?("#{k}=")
      end if opts
      @persisted = persisted
    end

    def persisted?
      @persisted
    end

    class << self
      attr_reader :from_prefix, :to_prefix
      def rename_to_save(hash)
        @rename_to_save.each_pair{ |from, to| old = hash[from]; hash[to] = old unless old.nil? } if @rename_to_save
      end
      def supplemental?(key)
        @supplemental and @supplemental.include?(key.to_sym)
      end
      protected
        def account_prefix(opts)
          @from_prefix = opts[:from].to_s
          @to_prefix = opts[:to].to_s
          @rename_to_save = opts[:rename_to_save]
          @supplemental = Array opts[:supplemental]
        end
        def attr_aria(*args)
          define_attribute_methods args.select{ |arg| arg.is_a? Symbol }
        end
    end

    def self.from_account_details(details)
      new(from_acct_details(details), persisted?(details))
    end
    def to_aria_attributes
      @attributes.inject({}) do |h,(k,v)|
        if self.class.supplemental?(k)
          (h[:supplemental] ||= {})[k] = v
        else
          h["#{self.class.to_prefix}#{k}"] = v
        end
        h
      end.tap{ |h| self.class.rename_to_save(h) }
    end

    protected
      def self.from_acct_details(details)
        details.attributes.inject({}) do |h,(k,v)|
          h[k[from_prefix.length..-1]] = v if k.starts_with?(from_prefix)
          h
        end
      end

      def self.persisted?(details)
        false
      end

    private
      def attribute=(attr, value)
        @attributes[attr] = value
      end
      def attribute(attr)
        @attributes[attr]
      end
  end
end
